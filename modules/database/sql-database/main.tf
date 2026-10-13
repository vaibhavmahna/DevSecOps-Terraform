resource "azurerm_mssql_database" "this" {
  name           = var.name
  server_id      = var.server_id
  sku_name       = var.sku_name
  max_size_gb    = var.max_size_gb
  zone_redundant = var.zone_redundant
  tags           = var.tags
}
