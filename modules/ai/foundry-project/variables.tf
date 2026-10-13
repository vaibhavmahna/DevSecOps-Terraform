variable "name" {
  type        = string
  description = "Name of the AI Foundry project."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "ai_services_hub_id" {
  type        = string
  description = "ID of the parent AI Foundry hub this project belongs to."
}

variable "friendly_name" {
  type        = string
  default     = null
  description = "Friendly display name for the project."
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the project."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
