resource "vault_identity_oidc" "issuer" {
  count  = var.issuer != "" ? 1 : 0
  issuer = var.issuer
}

resource "vault_identity_oidc_key" "key" {
  name               = var.key_name
  algorithm          = var.algorithm
  rotation_period    = var.rotation_period
  verification_ttl   = var.verification_ttl
  allowed_client_ids = length(var.allowed_client_ids) > 0 ? var.allowed_client_ids : ["*"]
}

resource "vault_identity_oidc_role" "role" {
  for_each = { for r in var.roles : r.name => r }

  name      = each.value.name
  key       = vault_identity_oidc_key.key.name
  ttl       = each.value.ttl
  template  = each.value.template != "" ? each.value.template : null
  client_id = each.value.client_id != "" ? each.value.client_id : null
}
