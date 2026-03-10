variable "name" {
  description = "Policy name"
  type        = string
}

variable "rules" {
  description = "List of path rules. Each rule defines a Vault path and allowed capabilities"
  type = list(object({
    path         = string
    capabilities = list(string)
  }))
}
