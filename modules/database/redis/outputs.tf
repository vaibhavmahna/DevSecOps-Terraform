output "id" {
  value       = azurerm_redis_cache.this.id
  description = "ID of the Redis cache."
}

output "hostname" {
  value       = azurerm_redis_cache.this.hostname
  description = "Hostname of the Redis cache."
}

output "primary_access_key" {
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
  description = "Primary access key for the Redis cache."
}
