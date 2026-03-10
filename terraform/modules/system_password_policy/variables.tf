variable "name" {
  description = "Name of the password policy"
  type        = string
}

variable "length" {
  description = "Length of generated passwords"
  type        = number
  default     = 20
}

variable "rules" {
  description = "List of charset rules. charset = allowed characters, min_chars = minimum required count from this set"
  type = list(object({
    charset   = string
    min_chars = number
  }))
  default = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 1 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 1 },
    { charset = "0123456789",                 min_chars = 1 },
  ]
}
