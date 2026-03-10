module "oidc_simple" {
  source           = "../../../modules/system_identity_oidc"
  key_name         = "demo-key"
  algorithm        = "RS256"
  rotation_period  = 86400
  verification_ttl = 172800
  roles            = []
}

module "oidc" {
  source           = "../../../modules/system_identity_oidc"
  key_name         = "apps"
  algorithm        = "RS256"
  rotation_period  = 86400
  verification_ttl = 172800

  roles = [
    {
      name      = "my-app"
      ttl       = 3600
      template  = "{\"groups\": {{identity.entity.groups.names}}, \"team\": {{identity.entity.metadata.team}}}"
      client_id = ""
    },
    {
      name      = "ci-pipeline"
      ttl       = 300
      template  = ""
      client_id = "ci-pipeline"
    },
  ]
}
