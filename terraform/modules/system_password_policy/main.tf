resource "vault_password_policy" "policy" {
  name = var.name
  policy = join("\n\n", concat(
    ["length = ${var.length}"],
    [for r in var.rules : "rule \"charset\" {\n  charset   = \"${r.charset}\"\n  min-chars = ${r.min_chars}\n}"]
  ))
}
