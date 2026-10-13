resource "azurerm_redis_cache" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  capacity             = var.capacity
  family               = var.family
  sku_name             = var.sku_name
  non_ssl_port_enabled = var.non_ssl_port_enabled
  minimum_tls_version  = var.minimum_tls_version
  tags                 = var.tags
}
