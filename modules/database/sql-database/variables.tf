variable "name" {
  type        = string
  description = "Name of the SQL database."
}

variable "server_id" {
  type        = string
  description = "ID of the parent SQL server this database belongs to."
}

variable "sku_name" {
  type        = string
  default     = "S0"
  description = "SKU name for the database. Supports both DTU-based names (e.g. S0, P1) and vCore-based names (e.g. GP_Gen5_2)."
}

variable "max_size_gb" {
  type        = number
  default     = null
  description = "Maximum size of the database in GB."
}

variable "zone_redundant" {
  type        = bool
  default     = false
  description = "Whether the database is zone redundant."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
