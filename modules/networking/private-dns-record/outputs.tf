output "id" {
  value       = azurerm_private_dns_a_record.this.id
  description = "ID of the private DNS A record."
}

output "fqdn" {
  value       = azurerm_private_dns_a_record.this.fqdn
  description = "Fully qualified domain name of the private DNS A record."
}
