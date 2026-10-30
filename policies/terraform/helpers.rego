package main

# Policies run against `terraform show -json tfplan`.
#   warn -> reported in the run summary, never blocks (same as the scans)
#   deny -> blocks the apply
# Every rule starts as warn; promote one to deny once it has run clean on
# real plans.

# Everything Terraform will manage after this apply: creates, updates and
# unchanged resources (no-op), with their planned attributes. Pure deletes
# are skipped since nothing will be left to check.
resources contains r if {
	some rc in input.resource_changes
	rc.mode == "managed"
	rc.change.actions != ["delete"]
	r := {"address": rc.address, "type": rc.type, "after": object.get(rc.change, "after", {})}
}

# Nested blocks (template, ingress, container, env...) appear as lists in
# plan JSON; an unset block is null or missing. Iterate either safely.
blocks(obj, name) := object.get(obj, name, []) if object.get(obj, name, []) != null
blocks(obj, name) := [] if object.get(obj, name, []) == null
