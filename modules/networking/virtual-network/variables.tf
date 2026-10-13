variable "name" {
  type        = string
  description = "Name of the virtual network."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the virtual network."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the virtual network."
}

variable "address_space" {
  type        = list(string)
  description = "List of address spaces (CIDR blocks) for the virtual network."
}

variable "dns_servers" {
  type        = list(string)
  description = "List of custom DNS server IP addresses for the virtual network."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the virtual network."
  default     = {}
}
