output "id" {
  value       = azurerm_application_insights.this.id
  description = "ID of the Application Insights component."
}

output "instrumentation_key" {
  value       = azurerm_application_insights.this.instrumentation_key
  description = "Instrumentation key for the Application Insights component."
  sensitive   = true
}

output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Connection string for the Application Insights component."
  sensitive   = true
}

output "app_id" {
  value       = azurerm_application_insights.this.app_id
  description = "Application ID of the Application Insights component."
}
