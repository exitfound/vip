resource "vault_audit" "file" {
  count = var.enable_file ? 1 : 0
  type  = "file"
  path  = "file"

  options = {
    file_path     = var.file_path
    mode          = var.file_mode
    format        = var.format
    log_raw       = tostring(var.log_raw)
    hmac_accessor = tostring(var.hmac_accessor)
  }
}

resource "vault_audit" "syslog" {
  count = var.enable_syslog ? 1 : 0
  type  = "syslog"
  path  = "syslog"

  options = {
    facility      = var.syslog_facility
    tag           = var.syslog_tag
    format        = var.format
    log_raw       = tostring(var.log_raw)
    hmac_accessor = tostring(var.hmac_accessor)
  }
}
