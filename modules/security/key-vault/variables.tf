variable "name" {
  type        = string
  description = "Name of the key vault."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the key vault."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the key vault."
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID used for authenticating requests to the key vault."
}

variable "sku_name" {
  type        = string
  description = "SKU name of the key vault (standard or premium)."
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be either 'standard' or 'premium'."
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days that items should be retained for once soft-deleted."
  default     = 90
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Whether to use Azure RBAC for authorization instead of vault access policies."
  default     = true
}

variable "access_policies" {
  type = list(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  description = "List of access policies to apply when enable_rbac_authorization is false."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the key vault."
  default     = {}
}
