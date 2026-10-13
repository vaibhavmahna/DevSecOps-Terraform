variable "name" {
  type        = string
  description = "Name of the Windows Web App."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the web app."
}

variable "location" {
  type        = string
  description = "Azure region in which to create the web app."
}

variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan hosting this web app."
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings (environment variables) for the web app."
  default     = {}
}

variable "docker_image_name" {
  type        = string
  description = "Docker image name and tag to run, e.g. mcr.microsoft.com/windows/servercore:ltsc2022. Leave null to omit the container stack."
  default     = null
}

variable "docker_registry_url" {
  type        = string
  description = "URL of the Docker registry hosting docker_image_name."
  default     = null
}

variable "always_on" {
  type        = bool
  description = "Whether the web app should always be loaded, even when idle."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the web app."
  default     = {}
}
