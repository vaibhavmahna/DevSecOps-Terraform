resource "azurerm_storage_share" "this" {
  name               = var.name
  storage_account_id = var.storage_account_id
  quota              = var.quota
}
