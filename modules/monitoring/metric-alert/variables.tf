variable "name" {
  type        = string
  description = "Name of the metric alert."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to create the metric alert."
}

variable "scopes" {
  type        = list(string)
  description = "Resource IDs of the resources being monitored by this alert."
}

variable "description" {
  type        = string
  description = "Description of the metric alert."
  default     = null
}

variable "severity" {
  type        = number
  description = "Severity of the alert, from 0 (critical) to 4 (verbose)."
  default     = 3
}

variable "frequency" {
  type        = string
  description = "Evaluation frequency of the alert, as an ISO 8601 duration."
  default     = "PT5M"
}

variable "window_size" {
  type        = string
  description = "Time window over which metrics are evaluated, as an ISO 8601 duration."
  default     = "PT15M"
}

variable "criteria" {
  type = object({
    metric_namespace = string
    metric_name      = string
    aggregation      = string
    operator         = string
    threshold        = number
  })
  description = "Single criteria defining the metric, aggregation, operator and threshold that trigger the alert."
}

variable "action_group_ids" {
  type        = list(string)
  description = "IDs of action groups to notify when the alert fires."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the metric alert."
  default     = {}
}
