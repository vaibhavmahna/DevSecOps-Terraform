output "id" {
  value       = azurerm_linux_function_app.this.id
  description = "ID of the function app."
}

output "name" {
  value       = azurerm_linux_function_app.this.name
  description = "Name of the function app."
}

output "default_hostname" {
  value       = azurerm_linux_function_app.this.default_hostname
  description = "Default hostname of the function app."
}

output "outbound_ip_addresses" {
  value       = azurerm_linux_function_app.this.outbound_ip_addresses
  description = "Outbound IP addresses of the function app."
}
