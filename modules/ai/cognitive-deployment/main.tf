resource "azurerm_cognitive_deployment" "this" {
  name                 = var.name
  cognitive_account_id = var.cognitive_account_id

  model {
    format  = var.model.format
    name    = var.model.name
    version = var.model.version
  }

  sku {
    name     = var.sku.name
    capacity = var.sku.capacity
  }

  version_upgrade_option = var.version_upgrade_option
}
