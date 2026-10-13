variable "name" {
  type        = string
  description = "Name of the Application Insights component."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the component."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the component."
}

variable "application_type" {
  type        = string
  description = "Type of application being monitored."
  default     = "web"
}

variable "workspace_id" {
  type        = string
  description = "ID of the Log Analytics workspace backing this workspace-based Application Insights resource."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the component."
  default     = {}
}
