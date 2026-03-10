module "password_policy_simple" {
  source = "../../../modules/system_password_policy"
  name   = "demo-password"
  length = 16

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 1 },
    { charset = "0123456789",                 min_chars = 1 },
  ]
}

module "password_policy_ops" {
  source = "../../../modules/system_password_policy"
  name   = "ops-password"
  length = 24

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 2 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 2 },
    { charset = "0123456789",                 min_chars = 2 },
    { charset = "!@#$%&*",                    min_chars = 1 },
  ]
}

module "password_policy_service" {
  source = "../../../modules/system_password_policy"
  name   = "service-password"
  length = 32

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 1 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 1 },
    { charset = "0123456789",                 min_chars = 1 },
  ]
}
