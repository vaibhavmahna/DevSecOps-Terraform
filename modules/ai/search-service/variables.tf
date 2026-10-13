variable "name" {
  type        = string
  description = "Name of the Azure AI Search service."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "sku" {
  type        = string
  default     = "standard"
  description = "Pricing tier of the search service (e.g. free, basic, standard, standard2, standard3)."
}

variable "replica_count" {
  type        = number
  default     = 1
  description = "Number of replicas for the search service."
}

variable "partition_count" {
  type        = number
  default     = 1
  description = "Number of partitions for the search service."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is allowed."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
