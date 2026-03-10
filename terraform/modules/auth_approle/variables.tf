variable "path" {
  description = "Mount path for the AppRole auth backend"
  type        = string
  default     = "approle"
}

variable "description" {
  description = "Human-readable description for the AppRole auth backend"
  type        = string
  default     = ""
}

variable "role_name" {
  description = "Name of the AppRole role"
  type        = string
}

variable "token_policies" {
  description = "List of Vault policies attached to tokens issued by this role"
  type        = list(string)
}

variable "token_ttl" {
  description = "Default TTL for issued tokens in seconds (e.g. 3600 = 1h)"
  type        = number
  default     = 3600
}

variable "token_max_ttl" {
  description = "Maximum TTL for issued tokens in seconds (e.g. 86400 = 24h)"
  type        = number
  default     = 86400
}

variable "token_num_uses" {
  description = "Number of uses per token. 0 = unlimited"
  type        = number
  default     = 0
}

variable "token_period" {
  description = "Period for periodic token in seconds. When set (non-zero) — token has no TTL, renews indefinitely. 0 = disabled"
  type        = number
  default     = 0
}

variable "token_type" {
  description = "Token type: default, service, or batch"
  type        = string
  default     = "default"
}

variable "bind_secret_id" {
  description = "Require secret_id during login"
  type        = bool
  default     = true
}

variable "secret_id_ttl" {
  description = "TTL for secret IDs in seconds. 0 = no expiry"
  type        = number
  default     = 0
}

variable "secret_id_num_uses" {
  description = "Number of uses per secret_id. 0 = unlimited"
  type        = number
  default     = 0
}

variable "secret_id_bound_cidrs" {
  description = "List of CIDRs from which secret_id can be used. Empty = no restriction"
  type        = list(string)
  default     = []
}

variable "token_bound_cidrs" {
  description = "List of CIDRs from which issued tokens can be used. Empty = no restriction"
  type        = list(string)
  default     = []
}

variable "generate_secret_id" {
  description = "Generate a secret_id and expose it as output (sensitive)"
  type        = bool
  default     = false
}
