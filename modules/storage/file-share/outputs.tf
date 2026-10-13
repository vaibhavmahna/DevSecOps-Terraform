output "id" {
  value       = azurerm_storage_share.this.id
  description = "ID of the file share."
}

output "url" {
  value       = azurerm_storage_share.this.url
  description = "URL of the file share."
}
