module "kv_demo" {
  source               = "../../../modules/secret_engine_kv"
  path                 = "demo"
  description          = "Demo KV v2 mount"
  max_versions         = 5
  cas_required         = false
  delete_version_after = ""
}

module "kv_my_app" {
  source               = "../../../modules/secret_engine_kv"
  path                 = "my-app"
  description          = "KV v2 secrets for my-app service"
  max_versions         = 10
  cas_required         = false
  delete_version_after = ""
}

module "kv_cicd" {
  source               = "../../../modules/secret_engine_kv"
  path                 = "cicd"
  description          = "KV v2 secrets for CI/CD pipelines"
  max_versions         = 5
  cas_required         = false
  delete_version_after = ""
}

module "kv_ops" {
  source               = "../../../modules/secret_engine_kv"
  path                 = "ops"
  description          = "KV v2 secrets for operations team"
  max_versions         = 10
  cas_required         = false
  delete_version_after = ""
}
