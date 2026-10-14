output "id" {
  value       = azurerm_ai_foundry_project.this.id
  description = "ID of the AI Foundry project."
}

output "principal_id" {
  value       = azurerm_ai_foundry_project.this.identity[0].principal_id
  description = "Principal ID of the project's managed identity."
}
