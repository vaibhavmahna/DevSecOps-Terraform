package main

# Run with: conftest verify --policy policies/terraform

tags := {"environment": "dev", "project": "plixa", "managed_by": "terraform"}

rc(type, after) := {
	"address": sprintf("%s.test", [type]),
	"mode": "managed",
	"type": type,
	"change": {"actions": ["create"], "after": after},
}

budget := rc("azurerm_consumption_budget_subscription", {"name": "budget"})

container_app(min_replicas, cpu, env) := rc("azurerm_container_app", {
	"location": "canadacentral",
	"tags": tags,
	"ingress": [{"allow_insecure_connections": false}],
	"template": [{"min_replicas": min_replicas, "container": [{"name": "app", "cpu": cpu, "env": env}]}],
})

# A plan shaped like plx-sandbox-app, with every setting compliant.
compliant := {"resource_changes": [
	budget,
	rc("azurerm_service_plan", {"sku_name": "F1", "location": "canadacentral", "tags": tags}),
	rc("azurerm_storage_account", {
		"account_replication_type": "LRS", "https_traffic_only_enabled": true,
		"min_tls_version": "TLS1_2", "allow_nested_items_to_be_public": false,
		"location": "canadacentral", "tags": tags,
	}),
	rc("azurerm_key_vault", {
		"sku_name": "standard", "purge_protection_enabled": true,
		"enable_rbac_authorization": true, "location": "canadacentral", "tags": tags,
	}),
	rc("azurerm_log_analytics_workspace", {"retention_in_days": 30, "location": "Canada Central", "tags": tags}),
	container_app(0, 0.25, [
		{"name": "APP_ENV", "value": "dev", "secret_name": null},
		{"name": "SIGNING_KEY", "value": null, "secret_name": "signing-key"},
	]),
	rc("azurerm_role_assignment", {"role_definition_name": "Key Vault Secrets User"}),
]}

with_change(change) := {"resource_changes": array.concat(compliant.resource_changes, [change])}

has_warning(prefix) if {
	some m in warn
	startswith(m, prefix)
}

test_compliant_plan_has_no_warnings if {
	count(warn) == 0 with input as compliant
}

# --- cost ----------------------------------------------------------------------

test_paid_service_plan if {
	has_warning("[cost] azurerm_service_plan.test: sku_name \"P1v2\"") with input as with_change(rc("azurerm_service_plan", {"sku_name": "P1v2", "location": "canadacentral", "tags": tags}))
}

test_container_app_not_scaling_to_zero if {
	has_warning("[cost] azurerm_container_app.test: min_replicas is 1") with input as with_change(container_app(1, 0.25, []))
}

test_container_app_too_big if {
	has_warning("[cost] azurerm_container_app.test: container \"app\" asks for 1") with input as with_change(container_app(0, 1, []))
}

test_geo_redundant_storage if {
	has_warning("[cost] azurerm_storage_account.test: replication \"GRS\"") with input as with_change(rc("azurerm_storage_account", {
		"account_replication_type": "GRS", "https_traffic_only_enabled": true,
		"min_tls_version": "TLS1_2", "allow_nested_items_to_be_public": false,
		"location": "canadacentral", "tags": tags,
	}))
}

test_long_log_retention if {
	has_warning("[cost] azurerm_log_analytics_workspace.test: retention 90") with input as with_change(rc("azurerm_log_analytics_workspace", {"retention_in_days": 90, "location": "canadacentral", "tags": tags}))
}

test_missing_budget if {
	has_warning("[cost] no consumption budget") with input as {"resource_changes": [
		rc("azurerm_service_plan", {"sku_name": "F1", "location": "canadacentral", "tags": tags}),
	]}
}

# --- security ------------------------------------------------------------------

test_key_vault_without_purge_protection if {
	has_warning("[security] azurerm_key_vault.test: purge protection is off") with input as with_change(rc("azurerm_key_vault", {
		"sku_name": "standard", "purge_protection_enabled": false,
		"enable_rbac_authorization": true, "location": "canadacentral", "tags": tags,
	}))
}

test_key_vault_with_access_policies if {
	has_warning("[security] azurerm_key_vault.test: uses access policies") with input as with_change(rc("azurerm_key_vault", {
		"sku_name": "standard", "purge_protection_enabled": true,
		"enable_rbac_authorization": false, "location": "canadacentral", "tags": tags,
	}))
}

test_key_vault_new_rbac_attribute_accepted if {
	not has_warning("[security] azurerm_key_vault.test: uses access policies") with input as with_change(rc("azurerm_key_vault", {
		"sku_name": "standard", "purge_protection_enabled": true,
		"rbac_authorization_enabled": true, "location": "canadacentral", "tags": tags,
	}))
}

test_public_blob_storage if {
	has_warning("[security] azurerm_storage_account.test: containers can be made public") with input as with_change(rc("azurerm_storage_account", {
		"account_replication_type": "LRS", "https_traffic_only_enabled": true,
		"min_tls_version": "TLS1_2", "allow_nested_items_to_be_public": true,
		"location": "canadacentral", "tags": tags,
	}))
}

test_insecure_ingress if {
	app := rc("azurerm_container_app", {
		"location": "canadacentral", "tags": tags,
		"ingress": [{"allow_insecure_connections": true}],
		"template": [{"min_replicas": 0, "container": []}],
	})
	has_warning("[security] azurerm_container_app.test: ingress allows plain HTTP") with input as with_change(app)
}

test_plain_secret_env if {
	has_warning("[security] azurerm_container_app.test: env DB_PASSWORD has a plain value") with input as with_change(container_app(0, 0.25, [{"name": "DB_PASSWORD", "value": "hunter2", "secret_name": null}]))
}

test_secret_warning_never_contains_value if {
	every m in warn {
		not contains(m, "hunter2")
	} with input as with_change(container_app(0, 0.25, [{"name": "DB_PASSWORD", "value": "hunter2", "secret_name": null}]))
}

test_secret_env_from_key_vault_allowed if {
	count(warn) == 0 with input as with_change(container_app(0, 0.25, [{"name": "APPLICATIONINSIGHTS_CONNECTION_STRING", "value": null, "secret_name": "appinsights"}]))
}

test_key_in_middle_of_name_not_flagged if {
	count(warn) == 0 with input as with_change(container_app(0, 0.25, [{"name": "MONKEY_MODE", "value": "on", "secret_name": null}]))
}

# --- governance ----------------------------------------------------------------

test_missing_tags if {
	has_warning("[governance] azurerm_service_plan.test: missing tags [\"managed_by\", \"project\"]") with input as with_change(rc("azurerm_service_plan", {"sku_name": "F1", "location": "canadacentral", "tags": {"environment": "dev"}}))
}

test_null_tags if {
	has_warning("[governance] azurerm_service_plan.test: missing tags") with input as with_change(rc("azurerm_service_plan", {"sku_name": "F1", "location": "canadacentral", "tags": null}))
}

test_disallowed_location if {
	has_warning("[governance] azurerm_service_plan.test: location \"eastus\"") with input as with_change(rc("azurerm_service_plan", {"sku_name": "F1", "location": "eastus", "tags": tags}))
}

# --- plan shape ----------------------------------------------------------------

test_deleted_resources_ignored if {
	deleted := {
		"address": "azurerm_service_plan.old", "mode": "managed", "type": "azurerm_service_plan",
		"change": {"actions": ["delete"], "after": null},
	}
	count(warn) == 0 with input as with_change(deleted)
}

test_data_sources_ignored if {
	ds := {
		"address": "data.azurerm_client_config.current", "mode": "data", "type": "azurerm_client_config",
		"change": {"actions": ["read"], "after": {"location": "eastus"}},
	}
	count(warn) == 0 with input as with_change(ds)
}
