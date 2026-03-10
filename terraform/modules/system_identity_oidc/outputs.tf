output "key_name" {
  description = "Name of the OIDC signing key"
  value       = vault_identity_oidc_key.key.name
}

output "role_client_ids" {
  description = "Map of role name to client_id — use as audience when validating OIDC tokens"
  value       = { for k, v in vault_identity_oidc_role.role : k => v.client_id }
}

output "issuer" {
  description = "OIDC issuer URL. Read from vault_identity_oidc if set, otherwise empty"
  value       = length(vault_identity_oidc.issuer) > 0 ? vault_identity_oidc.issuer[0].issuer : ""
}
