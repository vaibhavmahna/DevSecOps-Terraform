output "id" {
  value       = azurerm_mssql_database.this.id
  description = "ID of the SQL database."
}

output "name" {
  value       = azurerm_mssql_database.this.name
  description = "Name of the SQL database."
}
