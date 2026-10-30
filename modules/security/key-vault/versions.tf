terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # rbac_authorization_enabled replaced enable_rbac_authorization in 4.42.
      version = ">= 4.42.0, < 5.0.0"
    }
  }
}
