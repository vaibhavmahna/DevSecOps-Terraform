resource "azurerm_logic_app_standard" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = var.app_service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  app_settings = var.app_settings

  site_config {}

  tags = var.tags
}
