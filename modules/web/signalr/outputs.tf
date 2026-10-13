output "id" {
  value       = azurerm_signalr_service.this.id
  description = "ID of the SignalR service."
}

output "hostname" {
  value       = azurerm_signalr_service.this.hostname
  description = "Hostname of the SignalR service."
}

output "primary_access_key" {
  value       = azurerm_signalr_service.this.primary_access_key
  description = "Primary access key for the SignalR service."
  sensitive   = true
}
