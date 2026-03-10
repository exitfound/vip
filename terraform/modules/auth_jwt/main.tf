resource "vault_jwt_auth_backend" "jwt" {
  type              = "jwt"
  path              = var.path
  description       = var.description
  jwks_url          = var.jwks_url
  jwks_ca_pem       = var.jwks_ca_pem != "" ? var.jwks_ca_pem : null
  bound_issuer      = var.bound_issuer != "" ? var.bound_issuer : null
}

resource "vault_jwt_auth_backend_role" "role" {
  backend           = vault_jwt_auth_backend.jwt.path
  role_name         = var.role_name
  role_type         = var.role_type
  user_claim        = var.user_claim

  bound_audiences   = length(var.bound_audiences) > 0 ? var.bound_audiences : null
  bound_subject     = var.bound_subject != "" ? var.bound_subject : null
  bound_claims      = length(var.bound_claims) > 0 ? var.bound_claims : null

  token_policies    = var.token_policies
  token_ttl         = var.token_ttl
  token_max_ttl     = var.token_max_ttl
  token_num_uses    = var.token_num_uses
  token_type        = var.token_type
  token_bound_cidrs = length(var.token_bound_cidrs) > 0 ? var.token_bound_cidrs : null
}
