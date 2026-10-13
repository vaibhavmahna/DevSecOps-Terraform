variable "name" {
  type        = string
  description = "Name of the container registry."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the registry into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the registry into."
}

variable "sku" {
  type        = string
  description = "SKU of the container registry."
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Whether the admin user is enabled on the registry. Disabled by default for security."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
