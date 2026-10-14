terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  # The deploy SP is scoped to a single resource group (least-privilege),
  # not the whole subscription, so it can't register Resource Providers
  # subscription-wide. Assumes RPs needed by these modules are already
  # registered on this subscription from prior use.
  resource_provider_registrations = "none"
}
