variable "name" {
  type        = string
  description = "Name of the SignalR service."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the service."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the service."
}

variable "sku_name" {
  type        = string
  description = "SKU name of the SignalR service."
  default     = "Standard_S1"
}

variable "capacity" {
  type        = number
  description = "Number of units to allocate for the SKU."
  default     = 1
}

variable "service_mode" {
  type        = string
  description = "Mode the SignalR service operates in."
  default     = "Default"

  validation {
    condition     = contains(["Default", "Serverless", "Classic"], var.service_mode)
    error_message = "service_mode must be one of \"Default\", \"Serverless\", or \"Classic\"."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the service."
  default     = {}
}
