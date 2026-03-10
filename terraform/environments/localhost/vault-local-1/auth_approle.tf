module "auth_approle_simple" {
  source      = "../../../modules/auth_approle"
  path        = "approle-simple"
  description = "Simple AppRole backend"
  role_name   = "my-app-role-simple"

  token_policies        = [module.policy_app_simple.policy_name]
  token_ttl             = 3600
  token_max_ttl         = 7200
  token_num_uses        = 0
  token_period          = 0
  token_type            = "default"
  token_bound_cidrs     = []

  bind_secret_id        = true
  secret_id_ttl         = 0
  secret_id_num_uses    = 0
  secret_id_bound_cidrs = []
  generate_secret_id    = false
}

module "auth_approle" {
  source      = "../../../modules/auth_approle"
  path        = "approle"
  description = "AppRole auth for my-app service"
  role_name   = "my-app-role"

  token_policies        = [module.policy_app.policy_name]
  token_ttl             = 3600
  token_max_ttl         = 86400
  token_num_uses        = 0
  token_period          = 0
  token_type            = "default"
  token_bound_cidrs     = []

  bind_secret_id        = true
  secret_id_ttl         = 86400
  secret_id_num_uses    = 5
  secret_id_bound_cidrs = []
  generate_secret_id    = true
}
