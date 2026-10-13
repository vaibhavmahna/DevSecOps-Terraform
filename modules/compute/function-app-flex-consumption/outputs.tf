output "id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "ID of the function app."
}

output "name" {
  value       = azurerm_function_app_flex_consumption.this.name
  description = "Name of the function app."
}

output "default_hostname" {
  value       = azurerm_function_app_flex_consumption.this.default_hostname
  description = "Default hostname of the function app."
}
