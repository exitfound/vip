output "mount_path" {
  description = "Mount path of the JWT auth backend"
  value       = vault_jwt_auth_backend.jwt.path
}

output "role_name" {
  description = "Name of the created JWT auth role"
  value       = vault_jwt_auth_backend_role.role.role_name
}
