variable "name" {
  type        = string
  description = "Name of the Redis cache."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Size of the Redis cache, relative to the family (e.g. 0-6 for C family, 1-5 for P family)."
}

variable "family" {
  type        = string
  default     = "C"
  description = "SKU family for the Redis cache (C for Basic/Standard, P for Premium)."
}

variable "sku_name" {
  type        = string
  default     = "Standard"
  description = "SKU name for the Redis cache (Basic, Standard, Premium)."
}

variable "non_ssl_port_enabled" {
  type        = bool
  default     = false
  description = "Whether the non-SSL port (6379) is enabled. Disabled by default for security."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version required to connect to the cache."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
