output "id" {
  value       = azurerm_virtual_network.this.id
  description = "ID of the virtual network."
}

output "name" {
  value       = azurerm_virtual_network.this.name
  description = "Name of the virtual network."
}

output "address_space" {
  value       = azurerm_virtual_network.this.address_space
  description = "Address space of the virtual network."
}
