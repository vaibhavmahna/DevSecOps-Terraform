variable "name" {
  type        = string
  description = "Name of the Azure Bastion host."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the Azure Bastion host."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the Azure Bastion host."
}

variable "sku" {
  type        = string
  description = "SKU of the Azure Bastion host."
  default     = "Standard"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet used by the Bastion host. Must be a subnet literally named 'AzureBastionSubnet'."
}

variable "public_ip_address_id" {
  type        = string
  description = "ID of the public IP address used by the Bastion host."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Azure Bastion host."
  default     = {}
}
