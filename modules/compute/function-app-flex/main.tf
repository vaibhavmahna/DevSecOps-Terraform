# Targets a Flex Consumption plan via a standard azurerm_linux_function_app; verify this shape against current
# azurerm docs with `terraform validate` before first real use, since Flex Consumption support is newer/evolving
# (see also the dedicated module: modules/compute/function-app-flex-consumption).
resource "azurerm_linux_function_app" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = var.service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  app_settings = var.app_settings

  site_config {}

  tags = var.tags
}
