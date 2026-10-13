output "id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "ID of the Log Analytics workspace."
}

output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.workspace_id
  description = "Workspace (customer) ID of the Log Analytics workspace."
}

output "primary_shared_key" {
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  description = "Primary shared key used to connect agents to the workspace."
  sensitive   = true
}
