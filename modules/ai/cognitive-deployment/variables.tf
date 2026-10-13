variable "name" {
  type        = string
  description = "Name of the model deployment."
}

variable "cognitive_account_id" {
  type        = string
  description = "ID of the parent Cognitive Services account to deploy the model into."
}

variable "model" {
  type = object({
    format  = string
    name    = string
    version = string
  })
  description = "Model to deploy: format (e.g. OpenAI), name, and version."
}

variable "sku" {
  type = object({
    name     = string
    capacity = optional(number, 1)
  })
  description = "SKU for the deployment, including throughput capacity."
}

variable "version_upgrade_option" {
  type        = string
  default     = "OnceNewDefaultVersionAvailable"
  description = "Version upgrade behavior for the deployment when a new default model version becomes available."
}
