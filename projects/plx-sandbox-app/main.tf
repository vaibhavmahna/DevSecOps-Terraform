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
  storage_name = "stplxsbx${var.environment}01"
  webapp_name  = "app-plxsbx-${var.environment}-01"
}

# Modules are pinned to a module-library tag (?ref=modules-vX.Y.Z). `source`
# must be a literal string, so the URL can't come from a variable; bump every
# ref together when upgrading the library.
module "resource_group" {
  source   = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/general/resource-group?ref=modules-v1.0.0"
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# --- Network -----------------------------------------------------------------

module "vnet" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/networking/virtual-network?ref=modules-v1.0.0"
  name                = "vnet-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = [local.address_space]
  tags                = var.tags
}

module "app_subnet" {
  source               = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/networking/subnet?ref=modules-v1.0.0"
  name                 = "snet-app"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = [local.app_subnet]
  service_endpoints    = ["Microsoft.Storage"]
}

module "app_nsg" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/networking/nsg?ref=modules-v1.0.0"
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
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/monitoring/log-analytics?ref=modules-v1.0.0"
  name                = "log-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 30
  tags                = var.tags
}

# --- Storage -------------------------------------------------------------------

module "storage" {
  source                   = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/storage/storage-account?ref=modules-v1.0.0"
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
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/web/app-service-plan?ref=modules-v1.0.0"
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = "Linux"
  sku_name            = "F1"
  tags                = var.tags
}

module "web_app" {
  source              = "git::https://github.com/vaibhavmahna/DevSecOps-Terraform.git//modules/web/python-web-app?ref=modules-v1.0.0"
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
