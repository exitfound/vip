output "mount_path" {
  description = "Mount path of the userpass auth backend"
  value       = vault_auth_backend.userpass.path
}

output "accessor" {
  description = "Accessor of the userpass auth backend — use in identity_entity aliases"
  value       = vault_auth_backend.userpass.accessor
}

output "usernames" {
  description = "List of created usernames"
  value       = [for u in var.users : u.username]
}

output "initial_passwords" {
  description = "Initial passwords by username (sensitive). Read once via: terragrunt output -json initial_passwords_01 | jq. Then change via: vault write auth/<path>/users/<username>/password password=<new>"
  value       = { for k, v in random_password.user : k => v.result }
  sensitive   = true
}
