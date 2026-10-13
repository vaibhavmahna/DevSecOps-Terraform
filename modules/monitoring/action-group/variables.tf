variable "name" {
  type        = string
  description = "Name of the action group."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the action group."
}

variable "short_name" {
  type        = string
  description = "Short name of the action group, used in notifications. Maximum 12 characters."
}

variable "email_receivers" {
  type = list(object({
    name          = string
    email_address = string
  }))
  description = "List of email receivers to notify."
  default     = []
}

variable "webhook_receivers" {
  type = list(object({
    name        = string
    service_uri = string
  }))
  description = "List of webhook receivers to notify."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the action group."
  default     = {}
}
