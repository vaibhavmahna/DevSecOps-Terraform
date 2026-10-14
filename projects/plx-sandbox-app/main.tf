module "resource_group" {
  source   = "../../modules/general/resource-group"
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}
