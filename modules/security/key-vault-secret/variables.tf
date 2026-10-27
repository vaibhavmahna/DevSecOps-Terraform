variable "name" {
  type        = string
  description = "Name of the secret."
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault to store the secret in."
}

variable "value_wo" {
  type        = string
  description = "Secret value. Ephemeral and write-only: never saved to state or plan files."
  ephemeral   = true
  sensitive   = true
}

variable "value_wo_version" {
  type        = number
  description = "Increase this to write a new value (rotation). Terraform can't detect value changes on its own."
  default     = 1
}

variable "content_type" {
  type        = string
  description = "Optional hint describing the secret's format."
  default     = null
}

variable "expiration_date" {
  type        = string
  description = "Optional expiry as an RFC 3339 UTC timestamp, e.g. 2027-12-31T00:00:00Z."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the secret."
  default     = {}
}
