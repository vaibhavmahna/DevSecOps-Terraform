locals {
  # Non-overlapping address space per environment, so the VNets could be
  # peered later without renumbering.
  address_spaces = {
    dev     = "10.10.0.0/16"
    staging = "10.20.0.0/16"
    prod    = "10.30.0.0/16"
  }
  address_space = local.address_spaces[var.environment]
  app_subnet    = cidrsubnet(local.address_space, 8, 1)

  # Storage account and web app names are globally unique across Azure.
  storage_name   = "stplxsbx${var.environment}01"
  webapp_name    = "app-plxsbx-${var.environment}-01"
  key_vault_name = "kv-plxsbx-${var.environment}-01"

  # One image tag for every environment. Bumping it on dev and merging up
  # (dev -> staging -> master) promotes the exact image dev tested; nothing
  # is rebuilt per environment.
  devtools_image_tag = "2315313e7baece3dbc897a19274f8daf907f2fa2"
  devtools_image     = "ghcr.io/vaibhavmahna/plx-devtools:${local.devtools_image_tag}"
}

# Modules are pinned to a module-library tag (?ref=modules-vX.Y.Z). `source`
# must be a literal string, so the URL can't come from a variable; bump every
# ref together when upgrading the library.
module "resource_group" {
  source   = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/general/resource-group?ref=modules-v1.2.0"
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# --- Network -----------------------------------------------------------------

module "vnet" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/networking/virtual-network?ref=modules-v1.2.0"
  name                = "vnet-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = [local.address_space]
  tags                = var.tags
}

module "app_subnet" {
  source               = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/networking/subnet?ref=modules-v1.2.0"
  name                 = "snet-app"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [local.app_subnet]
  service_endpoints    = ["Microsoft.Storage"]
}

module "app_nsg" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/networking/nsg?ref=modules-v1.2.0"
  name                = "nsg-${var.project_name}-app-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
  security_rules = [
    {
      name                       = "allow-https-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = module.app_subnet.id
  network_security_group_id = module.app_nsg.id
}

# --- Monitoring ----------------------------------------------------------------

module "log_analytics" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/monitoring/log-analytics?ref=modules-v1.2.0"
  name                = "log-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 30
  tags                = var.tags
}

# Workspace-based, so telemetry lands in the same workspace and shares its
# 5 GB/month free ingestion.
module "app_insights" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/monitoring/application-insights?ref=modules-v1.2.0"
  name                = "appi-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  application_type    = "web"
  workspace_id        = module.log_analytics.id
  tags                = var.tags
}

# --- Identity & secrets --------------------------------------------------------

data "azurerm_client_config" "current" {}

module "devtools_identity" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/security/managed-identity?ref=modules-v1.2.0"
  name                = "id-devtools-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

# RBAC mode (no access policies). Purge protection is always on in the module,
# so a deleted vault keeps its name reserved for the 7-day retention.
module "key_vault" {
  source                     = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/security/key-vault?ref=modules-v1.2.0"
  name                       = local.key_vault_name
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
  tags                       = var.tags
}

# The pipeline writes secrets; the app can only read them.
module "kv_pipeline_officer" {
  source       = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/security/key-vault-rbac?ref=modules-v1.2.0"
  key_vault_id = module.key_vault.id
  principal_id = data.azurerm_client_config.current.object_id
  role_name    = "Key Vault Secrets Officer"
}

module "kv_devtools_reader" {
  source       = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/security/key-vault-rbac?ref=modules-v1.2.0"
  key_vault_id = module.key_vault.id
  principal_id = module.devtools_identity.principal_id
  role_name    = "Key Vault Secrets User"
}

# New role assignments take a minute or two to apply, so writing a secret
# (or the app reading one) straight after creating them gets a 403.
resource "time_sleep" "kv_rbac_propagation" {
  create_duration = "90s"
  depends_on      = [module.kv_pipeline_officer, module.kv_devtools_reader]
}

# Ephemeral: generated during plan/apply and never written to state or plan.
ephemeral "random_password" "signing_key" {
  length  = 48
  special = false
}

# Bump value_wo_version to rotate: a new value is written, and the app picks
# it up on its next revision (it references the versionless ID).
module "signing_key" {
  source           = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/security/key-vault-secret?ref=modules-v1.2.0"
  name             = "devtools-signing-key"
  key_vault_id     = module.key_vault.id
  value_wo         = ephemeral.random_password.signing_key.result
  value_wo_version = 1
  content_type     = "text/plain"
  tags             = var.tags
  depends_on       = [time_sleep.kv_rbac_propagation]
}

# Passed through Key Vault rather than as a plain env var: the module's env
# map would print it in plan logs, and this repo's Actions logs are public.
module "appinsights_connection" {
  source           = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/security/key-vault-secret?ref=modules-v1.2.0"
  name             = "appinsights-connection-string"
  key_vault_id     = module.key_vault.id
  value_wo         = module.app_insights.connection_string
  value_wo_version = 1
  content_type     = "text/plain"
  tags             = var.tags
  depends_on       = [time_sleep.kv_rbac_propagation]
}

# --- Storage -------------------------------------------------------------------

module "storage" {
  source                   = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/storage/storage-account?ref=modules-v1.2.0"
  name                     = local.storage_name
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  tags                     = var.tags
}

# --- Web -----------------------------------------------------------------------

# F1 is the free App Service tier. The module defaults to P1v2, which is paid,
# so the SKU is always set explicitly here.
module "app_service_plan" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/web/app-service-plan?ref=modules-v1.2.0"
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = "Linux"
  sku_name            = "F1"
  tags                = var.tags
}

module "web_app" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/web/python-web-app?ref=modules-v1.2.0"
  name                = local.webapp_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  service_plan_id     = module.app_service_plan.id
  python_version      = "3.12"
  # Always On is not available on the F1 tier; leaving the module default
  # (true) makes the apply fail.
  always_on = false
  tags      = var.tags
}

# --- Containers ----------------------------------------------------------------

# Consumption-only environment: no standing cost. Logs go to the existing
# workspace, which stays well inside the 5 GB/month free ingestion.
module "container_app_environment" {
  source                     = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/compute/container-app-environment?ref=modules-v1.2.0"
  name                       = "cae-${var.project_name}-${var.environment}"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  log_analytics_workspace_id = module.log_analytics.id
  tags                       = var.tags
}

# Kept inside the Container Apps monthly free grant: smallest size, and
# min_replicas = 0 so it scales to zero (and costs nothing) when idle.
module "devtools_app" {
  source                       = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/compute/container-app?ref=modules-v1.2.0"
  name                         = "ca-devtools-${var.environment}"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_app_environment.id
  image                        = local.devtools_image
  cpu                          = 0.25
  memory                       = "0.5Gi"
  min_replicas                 = 0
  max_replicas                 = 1
  ingress = {
    external_enabled = true
    target_port      = 8000
  }
  health_check = {
    path = "/healthz"
    port = 8000
  }
  env = {
    APP_ENV     = var.environment
    APP_VERSION = substr(local.devtools_image_tag, 0, 7)
  }
  # Key Vault references, resolved by Container Apps with the app's identity.
  identity_ids = [module.devtools_identity.id]
  key_vault_secrets = {
    "signing-key" = {
      key_vault_secret_id = module.signing_key.versionless_id
      identity_id         = module.devtools_identity.id
    }
    "appinsights-connection" = {
      key_vault_secret_id = module.appinsights_connection.versionless_id
      identity_id         = module.devtools_identity.id
    }
  }
  secret_env = {
    SIGNING_KEY                           = "signing-key"
    APPLICATIONINSIGHTS_CONNECTION_STRING = "appinsights-connection"
  }
  tags = var.tags
}

# --- Cost guardrail --------------------------------------------------------------

module "budget" {
  source = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/governance/subscription-budget?ref=modules-v1.2.0"
  name   = "budget-${var.project_name}-${var.environment}"
  amount = 1
}
