module "policy_app_simple" {
  source = "../../../modules/vault_custom_policy"
  name   = "app-policy-simple"

  rules = [
    { path = "demo/data/*",            capabilities = ["read"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
  ]
}

module "policy_app" {
  source = "../../../modules/vault_custom_policy"
  name   = "app-policy"

  rules = [
    { path = "my-app/data/*",          capabilities = ["read", "list"] },
    { path = "my-app/metadata/*",      capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
    { path = "auth/token/renew-self",  capabilities = ["update"] },
  ]
}

module "policy_cicd_simple" {
  source = "../../../modules/vault_custom_policy"
  name   = "cicd-policy-simple"

  rules = [
    { path = "cicd/data/*",            capabilities = ["read"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
  ]
}

module "policy_cicd" {
  source = "../../../modules/vault_custom_policy"
  name   = "cicd-policy"

  rules = [
    { path = "cicd/data/*",            capabilities = ["read"] },
    { path = "cicd/metadata/*",        capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
  ]
}

module "policy_ops_simple" {
  source = "../../../modules/vault_custom_policy"
  name   = "ops-policy-simple"

  rules = [
    { path = "ops/data/*",             capabilities = ["read"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
  ]
}

module "policy_ops" {
  source = "../../../modules/vault_custom_policy"
  name   = "ops-policy"

  rules = [
    { path = "ops/data/*",             capabilities = ["read", "list"] },
    { path = "ops/metadata/*",         capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
    { path = "auth/token/renew-self",  capabilities = ["update"] },
  ]
}

module "policy_transit_simple" {
  source = "../../../modules/vault_custom_policy"
  name   = "transit-policy-simple"

  rules = [
    { path = "transit-simple/encrypt/demo-key", capabilities = ["update"] },
    { path = "transit-simple/decrypt/demo-key", capabilities = ["update"] },
  ]
}

module "policy_transit" {
  source = "../../../modules/vault_custom_policy"
  name   = "transit-policy"

  rules = [
    { path = "auth/token/lookup-self",     capabilities = ["read"] },
    { path = "transit/encrypt/autounseal", capabilities = ["update"] },
    { path = "transit/decrypt/autounseal", capabilities = ["update"] },
  ]
}
