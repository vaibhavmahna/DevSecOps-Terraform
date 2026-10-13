variable "name" {
  type        = string
  description = "Name of the Cosmos DB account."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "offer_type" {
  type        = string
  default     = "Standard"
  description = "Offer type for the Cosmos DB account."
}

variable "kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "Kind of Cosmos DB account (GlobalDocumentDB, MongoDB, Parse)."
}

variable "consistency_level" {
  type        = string
  default     = "Session"
  description = "Consistency level for the account."

  validation {
    condition     = contains(["Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong"], var.consistency_level)
    error_message = "consistency_level must be one of: Eventual, ConsistentPrefix, Session, BoundedStaleness, Strong."
  }
}

variable "geo_locations" {
  type = list(object({
    location          = string
    failover_priority = number
  }))
  description = "List of geo-replication locations for the account. At least one location is required."

  validation {
    condition     = length(var.geo_locations) > 0
    error_message = "At least one geo_location must be specified."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
