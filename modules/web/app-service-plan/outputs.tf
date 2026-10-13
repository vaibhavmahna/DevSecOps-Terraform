output "id" {
  value       = azurerm_service_plan.this.id
  description = "ID of the App Service Plan."
}

output "name" {
  value       = azurerm_service_plan.this.name
  description = "Name of the App Service Plan."
}
