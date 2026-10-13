resource "azurerm_role_assignment" "this" {
  scope                = var.scope
  principal_id         = var.principal_id
  role_definition_name = var.role_definition_name
  role_definition_id   = var.role_definition_id
  description          = var.description

  lifecycle {
    precondition {
      condition     = (var.role_definition_name != null) != (var.role_definition_id != null)
      error_message = "Exactly one of role_definition_name or role_definition_id must be set."
    }
  }
}
