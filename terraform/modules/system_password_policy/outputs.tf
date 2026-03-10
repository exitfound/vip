output "policy_name" {
  description = "Name of the created password policy"
  value       = vault_password_policy.policy.name
}
