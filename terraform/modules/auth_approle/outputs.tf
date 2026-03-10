output "role_id" {
  description = "AppRole role_id — used as login credential together with secret_id"
  value       = vault_approle_auth_backend_role.role.role_id
}

output "secret_id" {
  description = "Generated secret_id (sensitive). Only available when generate_secret_id = true"
  value       = var.generate_secret_id ? vault_approle_auth_backend_role_secret_id.secret_id[0].secret_id : null
  sensitive   = true
}

output "secret_id_accessor" {
  description = "Accessor for the generated secret_id. Only available when generate_secret_id = true"
  value       = var.generate_secret_id ? vault_approle_auth_backend_role_secret_id.secret_id[0].accessor : null
}

output "mount_path" {
  description = "Mount path of the AppRole auth backend"
  value       = vault_auth_backend.approle.path
}

output "role_name" {
  description = "Name of the created AppRole role"
  value       = vault_approle_auth_backend_role.role.role_name
}
