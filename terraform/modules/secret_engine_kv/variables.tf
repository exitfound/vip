variable "path" {
  description = "Mount path for the KV v2 secrets engine"
  type        = string
  default     = "secret"
}

variable "description" {
  description = "Human-readable description for the KV v2 mount"
  type        = string
  default     = ""
}

variable "max_versions" {
  description = "Maximum number of versions to retain per secret. 0 = unlimited"
  type        = number
  default     = 10
}

variable "cas_required" {
  description = "Require check-and-set (CAS) for all writes — prevents blind overwrites"
  type        = bool
  default     = false
}

variable "delete_version_after" {
  description = "Duration after which all new versions are automatically deleted. E.g. '768h' (32 days). Empty = disabled"
  type        = string
  default     = ""
}
