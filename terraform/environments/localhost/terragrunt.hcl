# Usage:
#   export VAULT_ADDR=http://your-vault:8200
#   export VAULT_TOKEN=hvs.xxx
#   cd <stack> && terragrunt apply

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_providers {
        vault = {
          source  = "hashicorp/vault"
          version = "~> 5.0"
        }
      }
      required_version = ">= 1.11.0"
    }
  EOF
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "vault" {}
  EOF
}
