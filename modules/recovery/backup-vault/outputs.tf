output "id" {
  value       = azurerm_recovery_services_vault.this.id
  description = "ID of the Recovery Services vault."
}

output "vm_backup_policy_id" {
  value       = try(azurerm_backup_policy_vm.this[0].id, null)
  description = "ID of the VM backup policy, or null if one was not created."
}
