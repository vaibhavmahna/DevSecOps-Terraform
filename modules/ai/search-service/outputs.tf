output "id" {
  value       = azurerm_search_service.this.id
  description = "ID of the search service."
}

output "primary_key" {
  value       = azurerm_search_service.this.primary_key
  sensitive   = true
  description = "Primary admin key for the search service."
}

output "query_keys" {
  value       = azurerm_search_service.this.query_keys
  description = "Query keys for the search service."
}
