output "vm_id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "ID of the virtual machine."
}

output "private_ip_address" {
  value       = azurerm_network_interface.this.private_ip_address
  description = "Private IP address assigned to the virtual machine's network interface."
}

output "nic_id" {
  value       = azurerm_network_interface.this.id
  description = "ID of the virtual machine's network interface."
}
