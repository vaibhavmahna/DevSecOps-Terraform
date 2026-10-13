output "id" {
  value       = azurerm_virtual_machine_extension.this.id
  description = "ID of the virtual machine extension."
}

output "name" {
  value       = azurerm_virtual_machine_extension.this.name
  description = "Name of the virtual machine extension."
}
