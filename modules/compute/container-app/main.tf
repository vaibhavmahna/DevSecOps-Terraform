resource "azurerm_container_app" "this" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }

      # Liveness restarts a stuck container; readiness keeps traffic away
      # until the app answers. Both hit the same endpoint.
      dynamic "liveness_probe" {
        for_each = var.health_check != null ? [var.health_check] : []
        content {
          transport = "HTTP"
          path      = liveness_probe.value.path
          port      = liveness_probe.value.port
        }
      }

      dynamic "readiness_probe" {
        for_each = var.health_check != null ? [var.health_check] : []
        content {
          transport = "HTTP"
          path      = readiness_probe.value.path
          port      = readiness_probe.value.port
        }
      }
    }
  }

  dynamic "ingress" {
    for_each = var.ingress != null ? [var.ingress] : []
    content {
      external_enabled = ingress.value.external_enabled
      target_port      = ingress.value.target_port

      traffic_weight {
        latest_revision = true
        percentage      = 100
      }
    }
  }

  tags = var.tags
}
