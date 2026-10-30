package main

# "No cost should be involved": every SKU and size must stay inside a free
# tier or a monthly free grant.

# F1 = free App Service; Y1/FC1 = consumption plans with a monthly free grant.
allowed_service_plan_skus := {"F1", "Y1", "FC1"}

allowed_storage_replication := {"LRS"}

# Log Analytics retention up to 31 days is free.
max_log_retention_days := 31

# 0.25 vCPU / 0.5 GiB stretches the Container Apps free grant to ~200 h/month.
max_container_cpu := 0.25

warn contains msg if {
	some r in resources
	r.type == "azurerm_service_plan"
	not r.after.sku_name in allowed_service_plan_skus
	msg := sprintf("[cost] %s: sku_name %q is not a free tier (allowed: %v)", [r.address, r.after.sku_name, sort(allowed_service_plan_skus)])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_container_app"
	some t in blocks(r.after, "template")
	t.min_replicas > 0
	msg := sprintf("[cost] %s: min_replicas is %v; use 0 so it scales to zero (and costs nothing) when idle", [r.address, t.min_replicas])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_container_app"
	some t in blocks(r.after, "template")
	some c in blocks(t, "container")
	c.cpu > max_container_cpu
	msg := sprintf("[cost] %s: container %q asks for %v vCPU (max %v)", [r.address, c.name, c.cpu, max_container_cpu])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_storage_account"
	not r.after.account_replication_type in allowed_storage_replication
	msg := sprintf("[cost] %s: replication %q costs more than LRS", [r.address, r.after.account_replication_type])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_log_analytics_workspace"
	r.after.retention_in_days > max_log_retention_days
	msg := sprintf("[cost] %s: retention %v days; over %v days is billed", [r.address, r.after.retention_in_days, max_log_retention_days])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_key_vault"
	r.after.sku_name != "standard"
	msg := sprintf("[cost] %s: sku_name %q; use standard", [r.address, r.after.sku_name])
}

warn contains msg if {
	count([r | some r in resources; startswith(r.type, "azurerm_consumption_budget_")]) == 0
	msg := "[cost] no consumption budget in this plan; every project needs a budget alert"
}
