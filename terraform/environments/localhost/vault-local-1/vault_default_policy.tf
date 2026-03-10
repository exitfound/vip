module "default_policy" {
  source = "../../../modules/vault_default_policy"

  extra_rules = [
    { path = "sys/mounts",       capabilities = ["read"] },
    { path = "sys/policies/acl", capabilities = ["list"] },
  ]
}
