package main

required_tags := {"environment", "project", "managed_by"}

allowed_locations := {"canadacentral"}

# Only resources that support tags (the attribute exists in the plan).
warn contains msg if {
	some r in resources
	"tags" in object.keys(r.after)
	tags := object.get(r.after, "tags", {})
	missing := {t | some t in required_tags; not has_tag(tags, t)}
	count(missing) > 0
	msg := sprintf("[governance] %s: missing tags %v", [r.address, sort(missing)])
}

has_tag(tags, t) if {
	tags != null
	tags[t] != ""
}

# Azure accepts both "canadacentral" and "Canada Central".
warn contains msg if {
	some r in resources
	loc := r.after.location
	not normalize(loc) in allowed_locations
	msg := sprintf("[governance] %s: location %q is outside the allowed regions %v", [r.address, loc, sort(allowed_locations)])
}

normalize(loc) := lower(replace(loc, " ", ""))
