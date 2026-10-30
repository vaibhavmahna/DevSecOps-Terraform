package main

# Env var names that usually hold a credential. A container env var with one
# of these names must come from a secret (Key Vault reference), not a value.
secret_like_name := `(?i)(secret|passw(or)?d|token|api_?key|access_?key|private_?key|connection_?string|(^|_)key$)`

warn contains msg if {
	some r in resources
	r.type == "azurerm_key_vault"
	r.after.purge_protection_enabled != true
	msg := sprintf("[security] %s: purge protection is off; a deleted vault's secrets could be destroyed for good", [r.address])
}

kv_rbac(after) if after.rbac_authorization_enabled == true

# Deprecated name (removed in azurerm 5.0); still what modules set today.
kv_rbac(after) if after.enable_rbac_authorization == true

warn contains msg if {
	some r in resources
	r.type == "azurerm_key_vault"
	not kv_rbac(r.after)
	msg := sprintf("[security] %s: uses access policies; use RBAC authorization", [r.address])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_storage_account"
	r.after.https_traffic_only_enabled != true
	msg := sprintf("[security] %s: allows plain HTTP", [r.address])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_storage_account"
	r.after.min_tls_version != "TLS1_2"
	msg := sprintf("[security] %s: min_tls_version %q; require TLS1_2", [r.address, r.after.min_tls_version])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_storage_account"
	r.after.allow_nested_items_to_be_public != false
	msg := sprintf("[security] %s: containers can be made public; set allow_nested_items_to_be_public = false", [r.address])
}

warn contains msg if {
	some r in resources
	r.type in {"azurerm_linux_web_app", "azurerm_windows_web_app"}
	r.after.https_only != true
	msg := sprintf("[security] %s: https_only is off", [r.address])
}

warn contains msg if {
	some r in resources
	r.type == "azurerm_container_app"
	some i in blocks(r.after, "ingress")
	i.allow_insecure_connections == true
	msg := sprintf("[security] %s: ingress allows plain HTTP", [r.address])
}

# Only the name is reported, never the value.
warn contains msg if {
	some r in resources
	r.type == "azurerm_container_app"
	some t in blocks(r.after, "template")
	some c in blocks(t, "container")
	some e in blocks(c, "env")
	regex.match(secret_like_name, e.name)
	not object.get(e, "value", null) in {null, ""}
	msg := sprintf("[security] %s: env %s has a plain value; load it from Key Vault via secret_name", [r.address, e.name])
}
