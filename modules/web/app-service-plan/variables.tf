variable "name" {
  type        = string
  description = "Name of the App Service Plan."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the plan."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the plan."
}

variable "os_type" {
  type        = string
  description = "Operating system for the plan."
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either \"Linux\" or \"Windows\"."
  }
}

variable "sku_name" {
  type        = string
  description = "SKU name for the plan, e.g. P1v2."
  default     = "P1v2"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the plan."
  default     = {}
}
