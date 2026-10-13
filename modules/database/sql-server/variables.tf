variable "name" {
  type        = string
  description = "Name of the SQL server."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "administrator_login" {
  type        = string
  description = "Administrator login username for the SQL server."
}

variable "administrator_login_password" {
  type        = string
  sensitive   = true
  description = "Administrator login password for the SQL server. No default is provided; must be supplied by the caller."
}

variable "version" {
  type        = string
  default     = "12.0"
  description = "Version of the SQL server to create."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version required to connect to the server."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
