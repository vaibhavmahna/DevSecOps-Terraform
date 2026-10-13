variable "name" {
  type        = string
  description = "Name of the DNS A record (relative to the zone)."
}

variable "zone_name" {
  type        = string
  description = "Name of the parent private DNS zone."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the private DNS zone."
}

variable "ttl" {
  type        = number
  description = "Time-to-live of the DNS record, in seconds."
  default     = 300
}

variable "records" {
  type        = list(string)
  description = "List of IPv4 addresses for the A record."
}
