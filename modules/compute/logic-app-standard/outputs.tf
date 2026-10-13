output "id" {
  value       = azurerm_logic_app_standard.this.id
  description = "ID of the Logic App."
}

output "name" {
  value       = azurerm_logic_app_standard.this.name
  description = "Name of the Logic App."
}

output "default_hostname" {
  value       = azurerm_logic_app_standard.this.default_hostname
  description = "Default hostname of the Logic App."
}
