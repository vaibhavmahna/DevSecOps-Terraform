variable "name" {
  type        = string
  description = "Name of the private endpoint."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the private endpoint."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the private endpoint."
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet in which to create the private endpoint."
}

variable "private_connection_resource_id" {
  type        = string
  description = "ID of the resource to which the private endpoint connects."
}

variable "subresource_names" {
  type        = list(string)
  description = "List of subresource names to which the private endpoint connects (e.g. 'blob', 'vault', 'sqlServer')."
}

variable "is_manual_connection" {
  type        = bool
  description = "Whether the private endpoint connection requires manual approval."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the private endpoint."
  default     = {}
}
