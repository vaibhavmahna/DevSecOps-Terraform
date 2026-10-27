data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "this" {
  name            = var.name
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.amount
  time_grain      = "Monthly"

  # Budgets must start on the 1st of a month. Use the current month at
  # creation time, then ignore it so the next plan doesn't see a new date.
  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  dynamic "notification" {
    for_each = var.notifications
    content {
      enabled        = true
      operator       = "GreaterThanOrEqualTo"
      threshold      = notification.value.threshold
      threshold_type = notification.value.threshold_type
      contact_roles  = var.contact_roles
      contact_emails = var.contact_emails
    }
  }

  lifecycle {
    ignore_changes = [time_period]
  }
}
