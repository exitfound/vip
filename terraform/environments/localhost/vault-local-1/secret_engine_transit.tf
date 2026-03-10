module "transit_simple" {
  source      = "../../../modules/secret_engine_transit"
  name        = "demo-key"
  path        = "transit-simple"
  policy_name = module.policy_transit_simple.policy_name

  period                    = "168h"
  explicit_max_ttl          = ""
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 604800
  auto_rotate_period        = 0
  renewable                 = true
  no_default_policy         = false
  no_parent                 = true
  allow_plaintext_backup    = true
  deletion_allowed          = true
  exportable                = false
}

module "transit" {
  source      = "../../../modules/secret_engine_transit"
  name        = "autounseal"
  path        = "transit"
  policy_name = module.policy_transit.policy_name

  period                    = "8760h"
  explicit_max_ttl          = ""
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 31536000
  auto_rotate_period        = 0
  renewable                 = true
  no_default_policy         = true
  no_parent                 = true
  allow_plaintext_backup    = false
  deletion_allowed          = false
  exportable                = false
}
