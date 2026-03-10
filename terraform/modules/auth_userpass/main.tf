resource "vault_auth_backend" "userpass" {
  type        = "userpass"
  path        = var.path
  description = var.description
}

resource "random_password" "user" {
  for_each = { for u in var.users : u.username => u }
  length   = 32
  special  = false
}

# Устанавливает начальный пароль один раз при создании — Terraform его больше не трогает.
# После apply пользователь меняет пароль сам:
#   vault write auth/<path>/users/<username>/password password=<new>
resource "vault_generic_endpoint" "user_password" {
  for_each       = { for u in var.users : u.username => u }
  path           = "auth/${vault_auth_backend.userpass.path}/users/${each.key}"
  disable_read   = true
  disable_delete = true

  data_json = jsonencode({
    password = random_password.user[each.key].result
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

# Управляет конфигурацией пользователя (политики, TTL) — обновляется при каждом apply.
# Пароль не включён — Vault сохраняет существующий пароль при обновлении без него.
resource "vault_generic_endpoint" "user" {
  for_each             = { for u in var.users : u.username => u }
  path                 = "auth/${vault_auth_backend.userpass.path}/users/${each.key}"
  ignore_absent_fields = true
  depends_on           = [vault_generic_endpoint.user_password]

  data_json = jsonencode({
    token_policies    = each.value.token_policies
    token_ttl         = each.value.token_ttl
    token_max_ttl     = each.value.token_max_ttl
    token_type        = each.value.token_type
    token_num_uses    = each.value.token_num_uses
    token_bound_cidrs = each.value.token_bound_cidrs
  })
}
