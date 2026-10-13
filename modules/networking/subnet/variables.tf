variable "name" {
  type        = string
  description = "Name of the subnet."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the parent virtual network."
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the parent virtual network."
}

variable "address_prefixes" {
  type        = list(string)
  description = "List of address prefixes (CIDR blocks) for the subnet."
}

variable "service_endpoints" {
  type        = list(string)
  description = "List of service endpoints to associate with the subnet."
  default     = []
}
