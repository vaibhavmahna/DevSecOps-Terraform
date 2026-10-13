variable "name" {
  type        = string
  description = "Name of the Recovery Services vault."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the vault."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the vault."
}

variable "sku" {
  type        = string
  description = "SKU of the Recovery Services vault."
  default     = "Standard"
}

variable "soft_delete_enabled" {
  type        = bool
  description = "Whether soft delete is enabled for the vault."
  default     = true
}

variable "create_vm_backup_policy" {
  type        = bool
  description = "Whether to create a VM backup policy for this vault."
  default     = false
}

variable "vm_backup_policy_name" {
  type        = string
  description = "Name of the VM backup policy. Defaults to a name derived from the vault name when not set."
  default     = null
}

variable "backup_frequency" {
  type        = string
  description = "Frequency of VM backups."
  default     = "Daily"
}

variable "backup_time" {
  type        = string
  description = "Time of day at which backups are taken, in HH:MM format."
  default     = "23:00"
}

variable "retention_daily_count" {
  type        = number
  description = "Number of daily backup points to retain."
  default     = 7
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the vault."
  default     = {}
}
