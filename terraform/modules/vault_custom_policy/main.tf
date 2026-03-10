resource "vault_policy" "policy" {
  name   = var.name
  policy = join("\n\n", [
    for rule in var.rules :
    "path \"${rule.path}\" {\n  capabilities = [${join(", ", [for c in rule.capabilities : "\"${c}\""])}]\n}"
  ])
}
