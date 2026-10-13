resource "azurerm_app_configuration" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  sku                   = var.sku
  local_auth_enabled    = var.local_auth_enabled
  public_network_access = var.public_network_access
  tags                  = var.tags
}
