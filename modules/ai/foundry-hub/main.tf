# azurerm_ai_foundry is a newer/evolving resource type; verify its exact schema with `terraform validate` against current azurerm docs before first real use.
resource "azurerm_ai_foundry" "this" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  storage_account_id      = var.storage_account_id
  key_vault_id            = var.key_vault_id
  application_insights_id = var.application_insights_id
  friendly_name           = var.friendly_name
  tags                    = var.tags
}
