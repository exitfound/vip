output "entity_id" {
  description = "ID of the created identity entity"
  value       = vault_identity_entity.entity.id
}

output "entity_name" {
  description = "Name of the created identity entity"
  value       = vault_identity_entity.entity.name
}

output "alias_ids" {
  description = "Map of alias name to alias ID"
  value       = { for k, v in vault_identity_entity_alias.alias : k => v.id }
}
