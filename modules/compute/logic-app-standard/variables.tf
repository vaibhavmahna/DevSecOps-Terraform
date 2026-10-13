variable "name" {
  type        = string
  description = "Name of the Logic App (Standard)."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the Logic App into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the Logic App into."
}

variable "app_service_plan_id" {
  type        = string
  description = "ID of the App Service Plan the Logic App runs on."
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account used by the Logic App runtime."
}

variable "storage_account_access_key" {
  type        = string
  description = "Access key of the storage account used by the Logic App runtime."
  sensitive   = true
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings for the Logic App."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
