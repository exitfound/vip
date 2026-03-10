variable "enable_file" {
  description = "Enable file audit device"
  type        = bool
  default     = true
}

variable "file_path" {
  description = "Path on disk where Vault writes audit logs"
  type        = string
  default     = "/var/log/vault/audit.log"
}

variable "file_mode" {
  description = "Permissions mode for the audit log file (octal string)"
  type        = string
  default     = "0600"
}

variable "enable_syslog" {
  description = "Enable syslog audit device"
  type        = bool
  default     = false
}

variable "syslog_facility" {
  description = "Syslog facility to use"
  type        = string
  default     = "AUTH"
}

variable "syslog_tag" {
  description = "Syslog tag to use"
  type        = string
  default     = "vault"
}

variable "log_raw" {
  description = "Log raw sensitive data (tokens, keys). Only for debug — never in production"
  type        = bool
  default     = false
}

variable "hmac_accessor" {
  description = "HMAC token accessor in audit logs. Disable only for debugging"
  type        = bool
  default     = true
}

variable "format" {
  description = "Audit log format: json or jsonx"
  type        = string
  default     = "json"
}
