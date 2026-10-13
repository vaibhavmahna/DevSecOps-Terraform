resource "azurerm_communication_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location

  tags = var.tags
}
