resource "azurerm_recovery_services_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  soft_delete_enabled = var.soft_delete_enabled
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "this" {
  count               = var.create_vm_backup_policy ? 1 : 0
  name                = coalesce(var.vm_backup_policy_name, "${var.name}-vm-policy")
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name

  backup {
    frequency = var.backup_frequency
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily_count
  }
}
