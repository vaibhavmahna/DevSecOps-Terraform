variable "name" {
  type        = string
  description = "Name of the Log Analytics workspace."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the workspace."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the workspace."
}

variable "sku" {
  type        = string
  description = "Pricing tier of the Log Analytics workspace."
  default     = "PerGB2018"
}

variable "retention_in_days" {
  type        = number
  description = "Number of days to retain data in the workspace."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the workspace."
  default     = {}
}
