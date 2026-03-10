module "auth_userpass_simple" {
  source      = "../../../modules/auth_userpass"
  path        = "userpass-simple"
  description = "Simple userpass backend"

  users = [
    {
      username          = "demo-user"
      token_policies    = [module.policy_ops_simple.policy_name]
      token_ttl         = 3600
      token_max_ttl     = 3600
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
  ]
}

module "auth_userpass" {
  source      = "../../../modules/auth_userpass"
  path        = "userpass"
  description = "Userpass auth for operations team"

  users = [
    {
      username          = "alice"
      token_policies    = [module.policy_ops.policy_name]
      token_ttl         = 3600
      token_max_ttl     = 28800
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
    {
      username          = "bob"
      token_policies    = [module.policy_ops.policy_name]
      token_ttl         = 3600
      token_max_ttl     = 28800
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
  ]
}
