variable "path" {
  description = "Mount path for the userpass auth backend"
  type        = string
  default     = "userpass"
}

variable "description" {
  description = "Human-readable description for the userpass auth backend"
  type        = string
  default     = ""
}

variable "users" {
  description = "List of user configurations. Initial password is generated automatically via random_password and exposed as output. User changes it independently after first login"
  type = list(object({
    username          = string
    token_policies    = list(string)
    token_ttl         = number
    token_max_ttl     = number
    token_type        = string
    token_num_uses    = number
    token_bound_cidrs = list(string)
  }))
}

