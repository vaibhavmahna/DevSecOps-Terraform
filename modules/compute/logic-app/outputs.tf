output "id" {
  value       = azurerm_logic_app_workflow.this.id
  description = "ID of the Logic App workflow."
}

output "name" {
  value       = azurerm_logic_app_workflow.this.name
  description = "Name of the Logic App workflow."
}

output "access_endpoint" {
  value       = azurerm_logic_app_workflow.this.access_endpoint
  description = "Access endpoint of the Logic App workflow."
}
