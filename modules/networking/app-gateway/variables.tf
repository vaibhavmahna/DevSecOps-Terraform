variable "name" {
  type        = string
  description = "Name of the application gateway."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the application gateway."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the application gateway."
}

variable "sku_name" {
  type        = string
  description = "SKU name of the application gateway."
  default     = "Standard_v2"
}

variable "sku_tier" {
  type        = string
  description = "SKU tier of the application gateway."
  default     = "Standard_v2"
}

variable "capacity" {
  type        = number
  description = "Number of instances (capacity) for the application gateway."
  default     = 2
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet dedicated to the application gateway."
}

variable "public_ip_address_id" {
  type        = string
  description = "ID of the public IP address used for the application gateway's frontend."
}

variable "frontend_port" {
  type        = number
  description = "Frontend port on which the application gateway listens."
  default     = 80
}

variable "backend_address_fqdns" {
  type        = list(string)
  description = "List of backend FQDNs the application gateway forwards traffic to."
  default     = []
}

variable "backend_port" {
  type        = number
  description = "Backend port used by the application gateway's HTTP settings."
  default     = 80
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the application gateway."
  default     = {}
}
