variable "issuer" {
  description = "Issuer URL for the OIDC provider. E.g. https://vault.example.com. Empty = use Vault's default address"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of the OIDC signing key"
  type        = string
  default     = "default"
}

variable "algorithm" {
  description = "Signing algorithm for the OIDC key: RS256, RS384, RS512, ES256, ES384, ES512, EdDSA"
  type        = string
  default     = "RS256"
}

variable "rotation_period" {
  description = "How often to rotate the signing key in seconds. Default: 24h"
  type        = number
  default     = 86400
}

variable "verification_ttl" {
  description = "How long the public portion of the key remains valid after rotation in seconds. Default: 24h. Must be >= rotation_period"
  type        = number
  default     = 86400
}

variable "allowed_client_ids" {
  description = "List of client IDs (role client_ids) allowed to use this key. Empty = allow all"
  type        = list(string)
  default     = []
}

variable "roles" {
  description = "List of OIDC roles that use this key to sign tokens"
  type = list(object({
    name      = string
    ttl       = number  # token TTL in seconds
    template  = string  # JSON template for additional claims, "" = no extra claims
    client_id = string  # custom client ID for the role, "" = auto-generated
  }))
  default = []
}
