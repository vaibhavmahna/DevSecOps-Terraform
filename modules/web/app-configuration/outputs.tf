output "id" {
  value       = azurerm_app_configuration.this.id
  description = "ID of the App Configuration store."
}

output "endpoint" {
  value       = azurerm_app_configuration.this.endpoint
  description = "Endpoint URL of the App Configuration store."
}

output "primary_read_key" {
  value       = azurerm_app_configuration.this.primary_read_key[0].connection_string
  description = "Primary read-only connection string for the App Configuration store."
  sensitive   = true
}
