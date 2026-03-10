variable "extra_rules" {
  description = "Additional path rules appended to the base default policy. Base rules (lookup-self, renew-self, etc.) are always included and cannot be removed"
  type = list(object({
    path         = string
    capabilities = list(string)
  }))
  default = []
}
