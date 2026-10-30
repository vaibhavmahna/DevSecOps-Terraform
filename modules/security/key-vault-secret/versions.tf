terraform {
  # Write-only arguments need Terraform 1.11+.
  required_version = ">= 1.11.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # value_wo on azurerm_key_vault_secret was added in 4.23.0.
      version = ">= 4.23.0, < 5.0.0"
    }
  }
}
