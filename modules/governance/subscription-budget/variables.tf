variable "name" {
  type        = string
  description = "Name of the budget."
}

variable "amount" {
  type        = number
  description = "Monthly budget amount, in the billing currency of the subscription."
}

variable "notifications" {
  type = list(object({
    threshold      = number
    threshold_type = string
  }))
  description = "Alert thresholds as a percentage of the amount. threshold_type is Actual (spend so far) or Forecasted (projected month-end spend)."
  default = [
    { threshold = 50, threshold_type = "Actual" },
    { threshold = 100, threshold_type = "Forecasted" },
  ]

  validation {
    condition     = alltrue([for n in var.notifications : contains(["Actual", "Forecasted"], n.threshold_type)])
    error_message = "threshold_type must be Actual or Forecasted."
  }
}

variable "contact_roles" {
  type        = list(string)
  description = "Subscription roles to email when a threshold is hit. Keeps addresses out of code."
  default     = ["Owner"]
}

variable "contact_emails" {
  type        = list(string)
  description = "Extra email addresses to notify."
  default     = []
}
