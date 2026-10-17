output "resource_group_name" {
  value       = module.resource_group.name
  description = "Name of the created resource group."
}

output "resource_group_id" {
  value       = module.resource_group.id
  description = "ID of the created resource group."
}

output "vnet_address_space" {
  value       = module.vnet.address_space
  description = "Address space of this environment's virtual network."
}

output "app_subnet_id" {
  value       = module.app_subnet.id
  description = "ID of the app subnet."
}

output "web_app_url" {
  value       = "https://${module.web_app.default_hostname}"
  description = "Public URL of the web app."
}

output "storage_account_name" {
  value       = module.storage.name
  description = "Name of the storage account."
}

output "log_analytics_workspace_id" {
  value       = module.log_analytics.workspace_id
  description = "Workspace (customer) ID of the Log Analytics workspace."
}
