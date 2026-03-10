output "policy_name" {
  description = "Name of the default policy (always 'default')"
  value       = vault_policy.default.name
}

output "base_rules" {
  description = "Hardcoded base rules that are always present in the default policy"
  value       = local.base_rules
}
