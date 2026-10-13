variable "name" {
  type        = string
  description = "Name of the storage container."
}

variable "storage_account_id" {
  type        = string
  description = "ID of the parent storage account this container belongs to."
}

variable "container_access_type" {
  type        = string
  default     = "private"
  description = "Access level for the container."

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "container_access_type must be one of: private, blob, container."
  }
}
