variable "key_vault_id" {
  type        = string
  description = "ID of the key vault to scope the role assignment to."
}

variable "principal_id" {
  type        = string
  description = "Object ID of the principal (user, group, or service principal) to assign the role to."
}

variable "role_name" {
  type        = string
  description = "Name of the built-in Key Vault RBAC role to assign."
  default     = "Key Vault Secrets User"

  validation {
    condition = contains([
      "Key Vault Administrator",
      "Key Vault Secrets Officer",
      "Key Vault Secrets User",
      "Key Vault Certificates Officer",
      "Key Vault Crypto Officer",
      "Key Vault Crypto User",
    ], var.role_name)
    error_message = "role_name must be one of the standard Key Vault RBAC roles."
  }
}
