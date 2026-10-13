output "id" {
  value       = azurerm_cosmosdb_account.this.id
  description = "ID of the Cosmos DB account."
}

output "endpoint" {
  value       = azurerm_cosmosdb_account.this.endpoint
  description = "Endpoint URL of the Cosmos DB account."
}

output "primary_key" {
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
  description = "Primary key for the Cosmos DB account."
}
