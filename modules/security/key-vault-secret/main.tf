# value_wo is a write-only argument: Terraform sends it to Azure but never
# stores it in state or shows it in plan output. Terraform can't compare a
# value it doesn't keep, so bumping value_wo_version is what triggers a rotation.
resource "azurerm_key_vault_secret" "this" {
  name             = var.name
  key_vault_id     = var.key_vault_id
  value_wo         = var.value_wo
  value_wo_version = var.value_wo_version
  content_type     = var.content_type
  expiration_date  = var.expiration_date
  tags             = var.tags
}
