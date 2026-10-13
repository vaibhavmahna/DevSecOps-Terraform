output "id" {
  value       = azurerm_bastion_host.this.id
  description = "ID of the Azure Bastion host."
}

output "dns_name" {
  value       = azurerm_bastion_host.this.dns_name
  description = "FQDN of the Azure Bastion host."
}
