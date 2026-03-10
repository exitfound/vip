module "entity_simple" {
  source   = "../../../modules/system_identity_entity"
  name     = "demo-entity"
  metadata = { env = "demo" }
  disabled = false
  aliases  = []
}

module "entity_alice" {
  source   = "../../../modules/system_identity_entity"
  name     = "alice"
  metadata = { team = "ops", env = "prod" }
  disabled = false

  aliases = [
    {
      name           = "alice"
      mount_accessor = module.auth_userpass.accessor
    },
  ]
}

module "entity_bob" {
  source   = "../../../modules/system_identity_entity"
  name     = "bob"
  metadata = { team = "ops", env = "prod" }
  disabled = false

  aliases = [
    {
      name           = "bob"
      mount_accessor = module.auth_userpass.accessor
    },
  ]
}
