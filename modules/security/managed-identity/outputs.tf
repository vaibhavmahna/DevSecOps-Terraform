output "id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "ID of the managed identity."
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Principal (object) ID of the managed identity."
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Client ID of the managed identity."
}
