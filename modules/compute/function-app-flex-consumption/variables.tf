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
  description = "ID of the Flex Consumption App Service Plan to run the function app on."
}

variable "storage_container_endpoint" {
  type        = string
  description = "Blob container endpoint used to store the function app's deployment package."
}

variable "storage_authentication_type" {
  type        = string
  description = "Authentication type used to access the storage container."
  default     = "StorageAccountConnectionString"
}

variable "storage_access_key" {
  type        = string
  description = "Storage account access key, required when storage_authentication_type is StorageAccountConnectionString."
  default     = null
  sensitive   = true
}

variable "runtime_name" {
  type        = string
  description = "Language runtime for the function app (e.g. dotnet-isolated, node, python, java)."
}

variable "runtime_version" {
  type        = string
  description = "Version of the language runtime."
}

variable "maximum_instance_count" {
  type        = number
  description = "Maximum number of instances the function app can scale out to."
  default     = 100
}

variable "instance_memory_in_mb" {
  type        = number
  description = "Memory allocated per instance, in MB."
  default     = 2048
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
