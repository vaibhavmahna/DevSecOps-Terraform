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

    dynamic "application_stack" {
      for_each = var.docker_image_name != null ? [1] : []
      content {
        docker_image_name   = var.docker_image_name
        docker_registry_url = var.docker_registry_url
      }
    }
  }
}
