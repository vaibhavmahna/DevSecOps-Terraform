resource "azurerm_monitor_metric_alert" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  scopes              = var.scopes
  description         = var.description
  severity            = var.severity
  frequency           = var.frequency
  window_size         = var.window_size
  tags                = var.tags

  criteria {
    metric_namespace = var.criteria.metric_namespace
    metric_name      = var.criteria.metric_name
    aggregation      = var.criteria.aggregation
    operator         = var.criteria.operator
    threshold        = var.criteria.threshold
  }

  dynamic "action" {
    for_each = var.action_group_ids
    content {
      action_group_id = action.value
    }
  }
}
