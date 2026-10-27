variable "name" {
  type        = string
  description = "Name of the Container App Environment."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the environment into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the environment into."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Optional ID of a Log Analytics workspace to send container logs to. Null disables log shipping."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
