locals {
  base_rules = [
    { path = "auth/token/lookup-self",  capabilities = ["read"] },
    { path = "auth/token/renew-self",   capabilities = ["update"] },
    { path = "auth/token/revoke-self",  capabilities = ["update"] },
    { path = "sys/leases/renew",        capabilities = ["update"] },
    { path = "sys/leases/lookup",       capabilities = ["update"] },
    { path = "sys/capabilities-self",   capabilities = ["update"] },
  ]

  all_rules = concat(local.base_rules, var.extra_rules)
}

resource "vault_policy" "default" {
  name   = "default"
  policy = join("\n\n", [
    for rule in local.all_rules :
    "path \"${rule.path}\" {\n  capabilities = [${join(", ", [for c in rule.capabilities : "\"${c}\""])}]\n}"
  ])

  lifecycle {
    prevent_destroy = true
  }
}
