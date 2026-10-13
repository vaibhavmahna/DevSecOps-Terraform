output "assignment_id" {
  value       = azurerm_resource_group_policy_assignment.this.id
  description = "ID of the policy assignment."
}
