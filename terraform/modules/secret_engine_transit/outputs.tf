output "transit_token_value" {
  description = "Token with encrypt/decrypt permissions on the transit key"
  value       = vault_token.transit_token.client_token
  sensitive   = true
}

output "transit_policy_name" {
  description = "Name of the Vault policy attached to the transit token"
  value       = var.policy_name
}

output "transit_mount_path" {
  description = "Mount path of the Transit secrets engine"
  value       = vault_mount.transit_backend.path
}

output "transit_key_name" {
  description = "Name of the Transit encryption key"
  value       = vault_transit_secret_backend_key.transit_key.name
}
