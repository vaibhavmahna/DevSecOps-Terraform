resource "azurerm_private_dns_a_record" "this" {
  name                = var.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl
  records             = var.records
}
