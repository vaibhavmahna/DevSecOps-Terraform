output "id" {
  value       = azurerm_network_security_group.this.id
  description = "ID of the network security group."
}

output "name" {
  value       = azurerm_network_security_group.this.name
  description = "Name of the network security group."
}
