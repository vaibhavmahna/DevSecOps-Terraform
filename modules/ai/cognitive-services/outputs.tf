output "id" {
  value       = azurerm_cognitive_account.this.id
  description = "ID of the Cognitive Services account."
}

output "endpoint" {
  value       = azurerm_cognitive_account.this.endpoint
  description = "Endpoint URL of the Cognitive Services account."
}

output "primary_access_key" {
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
  description = "Primary access key for the Cognitive Services account."
}
