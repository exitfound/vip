module "auth_jwt_simple" {
  source      = "../../../modules/auth_jwt"
  path        = "jwt-simple"
  description = "Simple JWT backend"
  role_name   = "github-actions-simple"
  role_type   = "jwt"
  user_claim  = "sub"
  jwks_url    = "https://token.actions.githubusercontent.com/.well-known/jwks"
  jwks_ca_pem = ""

  bound_audiences   = ["https://github.com/my-org"]
  bound_claims      = {}
  bound_issuer      = ""
  bound_subject     = ""

  token_policies    = [module.policy_cicd_simple.policy_name]
  token_ttl         = 300
  token_max_ttl     = 300
  token_num_uses    = 0
  token_type        = "batch"
  token_bound_cidrs = []
}

module "auth_jwt" {
  source      = "../../../modules/auth_jwt"
  path        = "jwt"
  description = "JWT auth for GitHub Actions"
  role_name   = "github-actions"
  role_type   = "jwt"
  user_claim  = "sub"
  jwks_url    = "https://token.actions.githubusercontent.com/.well-known/jwks"
  jwks_ca_pem = ""

  bound_audiences   = ["https://github.com/my-org"]
  bound_claims      = { repository = "my-org/my-repo" }
  bound_issuer      = "https://token.actions.githubusercontent.com"
  bound_subject     = ""

  token_policies    = [module.policy_cicd.policy_name]
  token_ttl         = 300
  token_max_ttl     = 300
  token_num_uses    = 0
  token_type        = "batch"
  token_bound_cidrs = []
}
