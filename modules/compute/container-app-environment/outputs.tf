output "id" {
  value       = azurerm_container_app_environment.this.id
  description = "ID of the Container App Environment."
}

output "name" {
  value       = azurerm_container_app_environment.this.name
  description = "Name of the Container App Environment."
}

output "default_domain" {
  value       = azurerm_container_app_environment.this.default_domain
  description = "Default domain that apps in this environment are published under."
}

output "static_ip_address" {
  value       = azurerm_container_app_environment.this.static_ip_address
  description = "Static IP address of the environment."
}
