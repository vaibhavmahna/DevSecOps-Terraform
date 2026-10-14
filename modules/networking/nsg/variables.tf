variable "name" {
  type        = string
  description = "Name of the network security group."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the network security group."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the network security group."
}

variable "security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "List of security rules to apply to the network security group."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the network security group."
  default     = {}
}
