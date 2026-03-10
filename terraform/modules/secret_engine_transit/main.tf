resource "vault_mount" "transit_backend" {
  type                      = "transit"
  path                      = var.path
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
  max_lease_ttl_seconds     = var.max_lease_ttl_seconds
}

resource "vault_transit_secret_backend_key" "transit_key" {
  backend                   = trimsuffix(vault_mount.transit_backend.path, "/")
  name                      = var.name
  allow_plaintext_backup    = var.allow_plaintext_backup
  deletion_allowed          = var.deletion_allowed
  exportable                = var.exportable
  auto_rotate_period        = var.auto_rotate_period
}

resource "vault_token" "transit_token" {
  display_name              = "${var.name}-token"
  policies                  = [var.policy_name]
  period                    = var.period
  renewable                 = var.renewable
  no_default_policy         = var.no_default_policy
  no_parent                 = var.no_parent
  explicit_max_ttl          = var.explicit_max_ttl
}
