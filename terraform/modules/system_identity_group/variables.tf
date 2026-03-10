variable "name" {
  description = "Name of the identity group"
  type        = string
}

variable "type" {
  description = "Group type: 'internal' — members managed by Vault/Terraform; 'external' — members synced from external auth system (LDAP, GitHub, etc.)"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["internal", "external"], var.type)
    error_message = "type must be 'internal' or 'external'"
  }
}

variable "policies" {
  description = "List of Vault policies attached to this group. All member entities inherit these policies"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Map of metadata key-value pairs attached to this group"
  type        = map(string)
  default     = {}
}

variable "member_entity_ids" {
  description = "List of entity IDs to add as direct members. Only for internal groups"
  type        = list(string)
  default     = []
}

variable "member_group_ids" {
  description = "List of group IDs to add as sub-groups. Only for internal groups"
  type        = list(string)
  default     = []
}

variable "alias_name" {
  description = "Name of the group in the external auth system. E.g. CN of LDAP group, GitHub team slug. Only for external groups"
  type        = string
  default     = ""
}

variable "alias_mount_accessor" {
  description = "Accessor of the auth backend that provides external group membership. Only for external groups"
  type        = string
  default     = ""
}
