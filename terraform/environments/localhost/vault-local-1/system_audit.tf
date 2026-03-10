module "audit_file" {
  source        = "../../../modules/system_audit"
  enable_file   = true
  enable_syslog = false
  file_path     = "/var/log/vault/audit.log"
  file_mode     = "0600"
  log_raw       = false
  hmac_accessor = true
  format        = "json"
}

module "audit_syslog" {
  source          = "../../../modules/system_audit"
  enable_file     = false
  enable_syslog   = true
  log_raw         = false
  hmac_accessor   = true
  format          = "json"
  syslog_facility = "AUTH"
  syslog_tag      = "vault"
}
