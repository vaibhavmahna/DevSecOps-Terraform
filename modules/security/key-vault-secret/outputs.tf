output "id" {
  value       = azurerm_key_vault_secret.this.id
  description = "Versioned ID of the secret (pins one specific version)."
}

output "versionless_id" {
  value       = azurerm_key_vault_secret.this.versionless_id
  description = "Versionless ID of the secret. Consumers using this always get the latest version."
}

output "name" {
  value       = azurerm_key_vault_secret.this.name
  description = "Name of the secret."
}
