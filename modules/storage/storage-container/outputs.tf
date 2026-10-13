output "id" {
  value       = azurerm_storage_container.this.id
  description = "ID of the storage container."
}

output "name" {
  value       = azurerm_storage_container.this.name
  description = "Name of the storage container."
}
