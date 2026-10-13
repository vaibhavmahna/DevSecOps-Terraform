variable "name" {
  type        = string
  description = "Name of the function app."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the function app into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the function app into."
}

variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan to run the function app on."
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account used by the function app runtime."
}

variable "storage_account_access_key" {
  type        = string
  description = "Access key of the storage account used by the function app runtime."
  sensitive   = true
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings for the function app."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
