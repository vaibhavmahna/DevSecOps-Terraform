output "id" {
  value       = azurerm_storage_account.this.id
  description = "ID of the storage account."
}

output "name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the storage account."
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "Primary blob endpoint of the storage account."
}

output "primary_access_key" {
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
  description = "Primary access key for the storage account."
}
