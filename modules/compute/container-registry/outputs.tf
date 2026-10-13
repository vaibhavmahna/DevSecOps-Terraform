output "id" {
  value       = azurerm_container_registry.this.id
  description = "ID of the container registry."
}

output "name" {
  value       = azurerm_container_registry.this.name
  description = "Name of the container registry."
}

output "login_server" {
  value       = azurerm_container_registry.this.login_server
  description = "Login server URL of the container registry."
}

output "admin_username" {
  value       = azurerm_container_registry.this.admin_username
  description = "Admin username, populated only when admin_enabled is true."
}

output "admin_password" {
  value       = azurerm_container_registry.this.admin_password
  description = "Admin password, populated only when admin_enabled is true."
  sensitive   = true
}
