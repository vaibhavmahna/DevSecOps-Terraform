output "id" {
  value       = azurerm_key_vault.this.id
  description = "ID of the key vault."
}

output "vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "URI of the key vault."
}
