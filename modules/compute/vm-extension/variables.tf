variable "name" {
  type        = string
  description = "Name of the virtual machine extension."
}

variable "virtual_machine_id" {
  type        = string
  description = "ID of the virtual machine to attach the extension to."
}

variable "publisher" {
  type        = string
  description = "Publisher of the extension (e.g. Microsoft.Azure.Extensions)."
}

variable "type" {
  type        = string
  description = "Type of the extension (e.g. CustomScript)."
}

variable "type_handler_version" {
  type        = string
  description = "Version of the extension type handler."
}

variable "auto_upgrade_minor_version" {
  type        = bool
  description = "Whether the extension should automatically upgrade minor versions."
  default     = true
}

variable "settings" {
  type        = string
  description = "JSON-encoded public settings for the extension."
  default     = null
}

variable "protected_settings" {
  type        = string
  description = "JSON-encoded protected settings for the extension, not exposed in state reads."
  default     = null
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
