variable "name" {
  type        = string
  description = "Name of the App Configuration store."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the store."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the store."
}

variable "sku" {
  type        = string
  description = "SKU of the App Configuration store."
  default     = "standard"

  validation {
    condition     = contains(["free", "standard"], var.sku)
    error_message = "sku must be either \"free\" or \"standard\"."
  }
}

variable "local_auth_enabled" {
  type        = bool
  description = "Whether access key based authentication is allowed. Disabled by default in favor of RBAC/managed identity."
  default     = false
}

variable "public_network_access" {
  type        = string
  description = "Whether public network access is Enabled or Disabled for the store."
  default     = "Enabled"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the store."
  default     = {}
}
