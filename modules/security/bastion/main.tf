resource "azurerm_bastion_host" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags

  ip_configuration {
    name                 = "${var.name}-ipconf"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }
}
