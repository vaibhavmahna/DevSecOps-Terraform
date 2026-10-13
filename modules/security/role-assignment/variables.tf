variable "scope" {
  type        = string
  description = "Resource ID to scope the role assignment to."
}

variable "principal_id" {
  type        = string
  description = "Object ID of the principal (user, group, or service principal) to assign the role to."
}

variable "role_definition_name" {
  type        = string
  description = "Name of the built-in or custom role definition to assign. Exactly one of role_definition_name or role_definition_id must be set."
  default     = null
}

variable "role_definition_id" {
  type        = string
  description = "ID of the role definition to assign. Exactly one of role_definition_name or role_definition_id must be set."
  default     = null
}

variable "description" {
  type        = string
  description = "Description of the role assignment."
  default     = null
}
