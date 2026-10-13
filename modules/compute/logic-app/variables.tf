variable "name" {
  type        = string
  description = "Name of the Logic App workflow."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the workflow into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy the workflow into."
}

variable "workflow_parameters" {
  type        = map(string)
  description = "Parameters passed to the Logic App workflow definition."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
