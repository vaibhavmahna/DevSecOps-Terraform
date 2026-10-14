# azurerm_ai_foundry_project is a newer/evolving resource type; verify its exact schema with `terraform validate` against current azurerm docs before first real use.
resource "azurerm_ai_foundry_project" "this" {
  name               = var.name
  location           = var.location
  ai_services_hub_id = var.ai_services_hub_id
  friendly_name      = var.friendly_name
  description        = var.description
  tags               = var.tags
}
