resource "vault_identity_group" "group" {
  name              = var.name
  type              = var.type
  policies          = var.policies
  metadata          = var.metadata
  member_entity_ids = var.type == "internal" && length(var.member_entity_ids) > 0 ? var.member_entity_ids : null
  member_group_ids  = var.type == "internal" && length(var.member_group_ids) > 0 ? var.member_group_ids : null
}

resource "vault_identity_group_alias" "alias" {
  count = var.type == "external" && var.alias_name != "" ? 1 : 0

  name           = var.alias_name
  mount_accessor = var.alias_mount_accessor
  canonical_id   = vault_identity_group.group.id
}
