# Consumption-only environment (no workload profiles): no standing cost, apps
# are billed per second of use and can scale to zero.
resource "azurerm_container_app_environment" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}
