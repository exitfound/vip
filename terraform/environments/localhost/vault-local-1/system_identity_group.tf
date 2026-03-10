module "group_simple" {
  source            = "../../../modules/system_identity_group"
  name              = "demo-group"
  type              = "internal"
  policies          = []
  member_entity_ids = []
  member_group_ids  = []
  metadata          = { env = "demo" }
}

module "group_ops" {
  source            = "../../../modules/system_identity_group"
  name              = "ops-team"
  type              = "internal"
  policies          = []
  member_entity_ids = [module.entity_alice.entity_id, module.entity_bob.entity_id]
  member_group_ids  = []
  metadata          = { team = "ops" }
}
