resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = true
  app_settings        = var.app_settings
  tags                = var.tags

  site_config {
    always_on = var.always_on

    application_stack {
      python_version = var.python_version
    }
  }
}
