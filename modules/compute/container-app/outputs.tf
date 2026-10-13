output "id" {
  value       = azurerm_container_app.this.id
  description = "ID of the container app."
}

output "name" {
  value       = azurerm_container_app.this.name
  description = "Name of the container app."
}

output "latest_revision_fqdn" {
  value       = azurerm_container_app.this.latest_revision_fqdn
  description = "FQDN of the latest revision, if ingress is enabled."
}

output "outbound_ip_addresses" {
  value       = azurerm_container_app.this.outbound_ip_addresses
  description = "Outbound IP addresses of the container app."
}
