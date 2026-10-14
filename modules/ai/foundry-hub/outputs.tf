output "id" {
  value       = azurerm_ai_foundry.this.id
  description = "ID of the AI Foundry hub."
}

output "principal_id" {
  value       = azurerm_ai_foundry.this.identity[0].principal_id
  description = "Principal ID of the hub's managed identity."
}
