variable "path" {
  description = "Mount path for the JWT auth backend"
  type        = string
  default     = "jwt"
}

variable "description" {
  description = "Human-readable description for the JWT auth backend"
  type        = string
  default     = ""
}

variable "jwks_url" {
  description = "URL to fetch JWKS (JSON Web Key Sets) for JWT validation. E.g. https://token.actions.githubusercontent.com/.well-known/jwks"
  type        = string
}

variable "jwks_ca_pem" {
  description = "PEM-encoded CA certificate for the JWKS URL. Empty = use system CA"
  type        = string
  default     = ""
}

variable "bound_issuer" {
  description = "Expected issuer of the JWT (iss claim). E.g. https://token.actions.githubusercontent.com"
  type        = string
  default     = ""
}

variable "role_name" {
  description = "Name of the JWT auth role"
  type        = string
}

variable "role_type" {
  description = "Auth role type: jwt or oidc"
  type        = string
  default     = "jwt"
}

variable "bound_audiences" {
  description = "List of audiences the JWT must have (aud claim)"
  type        = list(string)
  default     = []
}

variable "bound_subject" {
  description = "Subject the JWT must have (sub claim). Empty = no restriction"
  type        = string
  default     = ""
}

variable "bound_claims" {
  description = "Map of claims the JWT must have. E.g. { repository = 'org/repo' }"
  type        = map(string)
  default     = {}
}

variable "user_claim" {
  description = "JWT claim to use as the username in Vault"
  type        = string
  default     = "sub"
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

variable "token_type" {
  description = "Token type: default, service, or batch"
  type        = string
  default     = "default"
}

variable "token_bound_cidrs" {
  description = "List of CIDRs from which issued tokens can be used. Empty = no restriction"
  type        = list(string)
  default     = []
}
