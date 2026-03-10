resource "vault_auth_backend" "approle" {
  type                  = "approle"
  path                  = var.path
  description           = var.description
}

resource "vault_approle_auth_backend_role" "role" {
  backend               = vault_auth_backend.approle.path
  role_name             = var.role_name
  token_policies        = var.token_policies

  token_ttl             = var.token_ttl
  token_max_ttl         = var.token_max_ttl
  token_num_uses        = var.token_num_uses
  token_period          = var.token_period != 0 ? var.token_period : null
  token_type            = var.token_type

  bind_secret_id        = var.bind_secret_id
  secret_id_ttl         = var.secret_id_ttl != 0 ? var.secret_id_ttl : null
  secret_id_num_uses    = var.secret_id_num_uses
  secret_id_bound_cidrs = length(var.secret_id_bound_cidrs) > 0 ? var.secret_id_bound_cidrs : null
  token_bound_cidrs     = length(var.token_bound_cidrs) > 0 ? var.token_bound_cidrs : null
}

resource "vault_approle_auth_backend_role_secret_id" "secret_id" {
  count                 = var.generate_secret_id ? 1 : 0
  backend               = vault_auth_backend.approle.path
  role_name             = vault_approle_auth_backend_role.role.role_name

  lifecycle {
    ignore_changes = [num_uses, ttl, metadata, cidr_list, token_bound_cidrs]
  }
}
