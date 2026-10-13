output "id" {
  value       = azurerm_subnet.this.id
  description = "ID of the subnet."
}

output "name" {
  value       = azurerm_subnet.this.name
  description = "Name of the subnet."
}

output "address_prefixes" {
  value       = azurerm_subnet.this.address_prefixes
  description = "Address prefixes of the subnet."
}
