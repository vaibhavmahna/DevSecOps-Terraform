resource "azurerm_policy_definition" "this" {
  count = var.create_custom_definition ? 1 : 0

  name         = var.custom_definition_name
  policy_type  = "Custom"
  mode         = var.mode
  display_name = var.custom_definition_display_name
  policy_rule  = var.policy_rule
  parameters   = var.parameters
}

locals {
  effective_policy_definition_id = var.create_custom_definition ? azurerm_policy_definition.this[0].id : var.policy_definition_id
}

resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = var.assignment_name
  resource_group_id    = var.resource_group_id
  policy_definition_id = local.effective_policy_definition_id
  display_name         = var.assignment_display_name
  parameters           = var.assignment_parameters
  enforce              = var.enforce
}
