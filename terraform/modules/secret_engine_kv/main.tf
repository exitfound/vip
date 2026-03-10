resource "vault_mount" "kv" {
  type        = "kv"
  path        = var.path
  description = var.description

  options = {
    version = "2"
  }
}

resource "vault_kv_secret_backend_v2" "config" {
  mount                = vault_mount.kv.path
  max_versions         = var.max_versions
  cas_required         = var.cas_required
  delete_version_after = var.delete_version_after != "" ? var.delete_version_after : null
}
