resource "azurerm_cognitive_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  kind                          = var.kind
  sku_name                      = var.sku_name
  custom_subdomain_name         = var.custom_subdomain_name
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}
