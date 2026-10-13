resource "azurerm_mssql_server" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  version                      = var.version
  minimum_tls_version          = var.minimum_tls_version
  tags                         = var.tags
}
