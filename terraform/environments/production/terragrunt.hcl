# Production environment — remote state в S3.

locals {
  bucket    = "YOUR-STATE-BUCKET"   # <-- заменить на свой бакет
  region    = "eu-central-1"
  profile   = "default"             # <-- AWS profile из ~/.aws/credentials
  state_key = "${path_relative_to_include()}/terraform.tfstate"
}

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

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "s3" {
        bucket  = "${local.bucket}"
        key     = "${local.state_key}"
        region  = "${local.region}"
        profile = "${local.profile}"
        encrypt      = true
        use_lockfile = true
      }
    }
  EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "vault" {}
  EOF
}
