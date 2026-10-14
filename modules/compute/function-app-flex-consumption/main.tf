# azurerm_function_app_flex_consumption is a newer/evolving resource type; double-check its exact schema
# against current azurerm docs with `terraform validate` before first real use.
resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = var.storage_container_endpoint
  storage_authentication_type = var.storage_authentication_type
  storage_access_key          = var.storage_access_key

  runtime_name    = var.runtime_name
  runtime_version = var.runtime_version

  maximum_instance_count = var.maximum_instance_count
  instance_memory_in_mb  = var.instance_memory_in_mb

  app_settings = var.app_settings

  site_config {}

  tags = var.tags
}
