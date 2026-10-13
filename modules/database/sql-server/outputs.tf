output "id" {
  value       = azurerm_mssql_server.this.id
  description = "ID of the SQL server."
}

output "fully_qualified_domain_name" {
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
  description = "Fully qualified domain name of the SQL server."
}
