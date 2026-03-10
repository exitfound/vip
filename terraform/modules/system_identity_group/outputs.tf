output "group_id" {
  description = "ID of the created identity group"
  value       = vault_identity_group.group.id
}

output "group_name" {
  description = "Name of the created identity group"
  value       = vault_identity_group.group.name
}

output "alias_id" {
  description = "ID of the group alias. Only set for external groups with alias_name configured"
  value       = length(vault_identity_group_alias.alias) > 0 ? vault_identity_group_alias.alias[0].id : null
}
