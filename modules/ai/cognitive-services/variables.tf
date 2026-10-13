variable "name" {
  type        = string
  description = "Name of the Cognitive Services account."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "kind" {
  type        = string
  default     = "CognitiveServices"
  description = "Kind of Cognitive Services account to create. CognitiveServices is the Azure resource type covering all Cognitive Services APIs (Vision, Language, etc.)."
}

variable "sku_name" {
  type        = string
  default     = "S0"
  description = "SKU name for the Cognitive Services account."
}

variable "custom_subdomain_name" {
  type        = string
  default     = null
  description = "Custom subdomain name used for token-based authentication endpoints. Required for features like Azure AD auth or Private Link."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is allowed. Setting this to false is more secure but requires a private endpoint for connectivity."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
