output "file_audit_path" {
  description = "Vault path of the file audit device (null if disabled)"
  value       = var.enable_file ? vault_audit.file[0].path : null
}

output "syslog_audit_path" {
  description = "Vault path of the syslog audit device (null if disabled)"
  value       = var.enable_syslog ? vault_audit.syslog[0].path : null
}

output "enabled_devices" {
  description = "List of enabled audit device types"
  value = compact([
    var.enable_file ? "file" : "",
    var.enable_syslog ? "syslog" : "",
  ])
}
