variable "name" {
  description = "Transit key name — used as base for policy and token names"
  type        = string
  default     = "autounseal"
}

variable "path" {
  description = "Mount path for the Transit secrets engine"
  type        = string
  default     = "transit"
}

variable "period" {
  description = "Renewal period for the periodic token — auto-renewed on each use"
  type        = string
  default     = "8760h"
}

variable "renewable" {
  description = "Allow manual token renewal via vault token renew"
  type        = bool
  default     = true
}

variable "no_default_policy" {
  description = "Exclude the default policy from the token"
  type        = bool
  default     = true
}

variable "no_parent" {
  description = "Create orphan token not tied to Terraform session token"
  type        = bool
  default     = true
}

variable "explicit_max_ttl" {
  description = "Hard cap on token lifetime regardless of renewals. Empty = no cap"
  type        = string
  default     = ""
}

variable "default_lease_ttl_seconds" {
  description = "Default lease TTL for the Transit mount in seconds"
  type        = number
  default     = 3600
}

variable "max_lease_ttl_seconds" {
  description = "Max lease TTL for the Transit mount in seconds — must be >= token period"
  type        = number
  default     = 31536000
}

variable "auto_rotate_period" {
  description = "Auto-rotation period for the transit key in seconds. 0 = disabled"
  type        = number
  default     = 0
}

variable "allow_plaintext_backup" {
  description = "Allow plaintext backup export of the transit key"
  type        = bool
  default     = false
}

variable "deletion_allowed" {
  description = "Allow deletion of the transit key via API"
  type        = bool
  default     = false
}

variable "exportable" {
  description = "Allow export of the transit key material"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "Name of the Vault policy to attach to the transit token"
  type        = string
}
