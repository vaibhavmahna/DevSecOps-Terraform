variable "name" {
  type        = string
  description = "Name of the user-assigned managed identity."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the managed identity."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the managed identity."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the managed identity."
  default     = {}
}
