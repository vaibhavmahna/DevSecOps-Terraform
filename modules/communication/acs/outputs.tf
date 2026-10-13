output "id" {
  value       = azurerm_communication_service.this.id
  description = "ID of the Azure Communication Services resource."
}

output "name" {
  value       = azurerm_communication_service.this.name
  description = "Name of the Azure Communication Services resource."
}

output "hostname" {
  value       = azurerm_communication_service.this.hostname
  description = "Hostname of the Azure Communication Services resource."
}
