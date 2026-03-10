resource "vault_identity_entity" "entity" {
  name     = var.name
  policies = var.policies
  metadata = var.metadata
  disabled = var.disabled
}

resource "vault_identity_entity_alias" "alias" {
  for_each = { for a in var.aliases : a.name => a }

  name           = each.value.name
  mount_accessor = each.value.mount_accessor
  canonical_id   = vault_identity_entity.entity.id
}
