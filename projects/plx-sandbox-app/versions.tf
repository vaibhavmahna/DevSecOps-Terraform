terraform {
  # 1.11 for write-only arguments (Key Vault secret value never reaches state).
  required_version = ">= 1.11.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.23"
    }
    # 3.7 adds the ephemeral random_password.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
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
