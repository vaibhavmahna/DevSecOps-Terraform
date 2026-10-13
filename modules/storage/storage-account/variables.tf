variable "name" {
  type        = string
  description = "Name of the storage account."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "Performance tier of the storage account (Standard or Premium)."
}

variable "account_replication_type" {
  type        = string
  default     = "LRS"
  description = "Replication type for the storage account."

  validation {
    condition     = contains(["LRS", "GRS", "ZRS", "RAGRS", "RAGZRS", "GZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of: LRS, GRS, ZRS, RAGRS, RAGZRS, GZRS."
  }
}

variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "Access tier for the storage account."

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "access_tier must be one of: Hot, Cool."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
