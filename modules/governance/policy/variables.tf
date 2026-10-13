variable "resource_group_id" {
  type        = string
  description = "ID of the resource group to scope the policy assignment to."
}

variable "create_custom_definition" {
  type        = bool
  description = "Whether to create a custom policy definition instead of assigning an existing one."
  default     = false
}

variable "policy_definition_id" {
  type        = string
  description = "ID of an existing (e.g. built-in) policy definition to assign. Required if create_custom_definition is false."
  default     = null
}

variable "custom_definition_name" {
  type        = string
  description = "Name of the custom policy definition. Required if create_custom_definition is true."
  default     = null
}

variable "custom_definition_display_name" {
  type        = string
  description = "Display name of the custom policy definition."
  default     = null
}

variable "policy_rule" {
  type        = string
  description = "JSON-encoded policy rule for the custom policy definition. Required if create_custom_definition is true."
  default     = null
}

variable "parameters" {
  type        = string
  description = "JSON-encoded parameter schema for the custom policy definition."
  default     = null
}

variable "mode" {
  type        = string
  description = "Mode of the custom policy definition."
  default     = "Indexed"
}

variable "assignment_name" {
  type        = string
  description = "Name of the policy assignment."
}

variable "assignment_display_name" {
  type        = string
  description = "Display name of the policy assignment."
  default     = null
}

variable "assignment_parameters" {
  type        = string
  description = "JSON-encoded parameter values for the policy assignment."
  default     = null
}
