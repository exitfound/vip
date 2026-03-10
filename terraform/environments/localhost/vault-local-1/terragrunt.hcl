# Usage:
#   export VAULT_ADDR=http://your-vault:8200
#   export VAULT_TOKEN=hvs.xxx
#   terragrunt apply

include "env" {
  path = find_in_parent_folders()
}
