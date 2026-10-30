resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  access_tier              = var.access_tier

  min_tls_version            = "TLS1_2"
  https_traffic_only_enabled = true
  # The provider default is true, which lets any container be made public.
  allow_nested_items_to_be_public = false

  tags = var.tags
}
