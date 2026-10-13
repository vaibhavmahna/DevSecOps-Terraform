resource "azurerm_logic_app_workflow" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  parameters          = var.workflow_parameters

  tags = var.tags
}
