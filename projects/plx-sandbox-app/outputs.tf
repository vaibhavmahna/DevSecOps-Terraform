output "resource_group_name" {
  value       = module.resource_group.name
  description = "Name of the created resource group."
}

output "resource_group_id" {
  value       = module.resource_group.id
  description = "ID of the created resource group."
}
