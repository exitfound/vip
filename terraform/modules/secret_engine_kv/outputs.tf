output "mount_path" {
  description = "Mount path of the KV v2 secrets engine"
  value       = vault_mount.kv.path
}

output "accessor" {
  description = "Accessor of the KV v2 mount — used in vault_identity_group_alias for external groups or Sentinel policies (Enterprise)"
  value       = vault_mount.kv.accessor
}
