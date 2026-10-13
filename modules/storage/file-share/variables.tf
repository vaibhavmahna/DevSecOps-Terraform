variable "name" {
  type        = string
  description = "Name of the file share."
}

variable "storage_account_id" {
  type        = string
  description = "ID of the parent storage account this file share belongs to."
}

variable "quota" {
  type        = number
  default     = 50
  description = "Maximum size of the file share, in GB."
}
