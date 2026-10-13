variable "name" {
  type        = string
  description = "Name of the Python Linux Web App."
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

variable "python_version" {
  type        = string
  description = "Python runtime version to use."
  default     = "3.12"
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings (environment variables) for the web app."
  default     = {}
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
