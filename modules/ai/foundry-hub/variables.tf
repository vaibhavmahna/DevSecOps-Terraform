variable "name" {
  type        = string
  description = "Name of the AI Foundry hub."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "storage_account_id" {
  type        = string
  description = "ID of the storage account backing this AI Foundry hub."
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault backing this AI Foundry hub."
}

variable "application_insights_id" {
  type        = string
  default     = null
  description = "ID of the Application Insights instance to associate with this hub."
}

variable "friendly_name" {
  type        = string
  default     = null
  description = "Friendly display name for the hub."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
