resource "azurerm_signalr_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = var.sku_name
    capacity = var.capacity
  }

  service_mode = var.service_mode
}
