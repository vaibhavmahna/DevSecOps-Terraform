variable "name" {
  type        = string
  description = "Name of the Azure Communication Services resource."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the resource into."
}

variable "data_location" {
  type        = string
  description = "Data residency location for the communication service (not an Azure region)."
  default     = "United States"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
