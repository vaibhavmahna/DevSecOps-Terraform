variable "name" {
  type        = string
  description = "Name of the container app."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the container app into."
}

variable "container_app_environment_id" {
  type        = string
  description = "ID of the Container App Environment the app runs in."
}

variable "revision_mode" {
  type        = string
  description = "Revision mode for the container app."
  default     = "Single"
}

variable "image" {
  type        = string
  description = "Container image to deploy (e.g. myregistry.azurecr.io/app:tag)."
}

variable "cpu" {
  type        = number
  description = "CPU cores allocated to the container."
  default     = 0.25
}

variable "memory" {
  type        = string
  description = "Memory allocated to the container (e.g. 0.5Gi)."
  default     = "0.5Gi"
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of replicas."
  default     = 0
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of replicas."
  default     = 1
}

variable "ingress" {
  type = object({
    external_enabled = bool
    target_port      = number
  })
  description = "Optional ingress configuration for the container app."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resource."
  default     = {}
}
