###################################################### Audit:
output "audit_file_path" {
  value = module.audit_file.file_audit_path
}

output "audit_syslog_path" {
  value = module.audit_syslog.syslog_audit_path
}

###################################################### Default Policy:
output "default_policy_name" {
  value = module.default_policy.policy_name
}

###################################################### Custom Policies:
output "policy_app_simple_name" {
  value = module.policy_app_simple.policy_name
}

output "policy_app_name" {
  value = module.policy_app.policy_name
}

output "policy_cicd_simple_name" {
  value = module.policy_cicd_simple.policy_name
}

output "policy_cicd_name" {
  value = module.policy_cicd.policy_name
}

output "policy_ops_simple_name" {
  value = module.policy_ops_simple.policy_name
}

output "policy_ops_name" {
  value = module.policy_ops.policy_name
}

output "policy_transit_simple_name" {
  value = module.policy_transit_simple.policy_name
}

output "policy_transit_name" {
  value = module.policy_transit.policy_name
}

###################################################### KV:
output "kv_demo_mount_path" {
  value = module.kv_demo.mount_path
}

output "kv_my_app_mount_path" {
  value = module.kv_my_app.mount_path
}

output "kv_cicd_mount_path" {
  value = module.kv_cicd.mount_path
}

output "kv_ops_mount_path" {
  value = module.kv_ops.mount_path
}

###################################################### AppRole:
output "auth_approle_simple_mount_path" {
  value = module.auth_approle_simple.mount_path
}

output "auth_approle_simple_role_id" {
  value = module.auth_approle_simple.role_id
}

output "auth_approle_mount_path" {
  value = module.auth_approle.mount_path
}

output "auth_approle_role_id" {
  value = module.auth_approle.role_id
}

output "auth_approle_secret_id" {
  value     = module.auth_approle.secret_id
  sensitive = true
}

output "auth_approle_secret_id_accessor" {
  value = module.auth_approle.secret_id_accessor
}

###################################################### JWT:
output "auth_jwt_simple_mount_path" {
  value = module.auth_jwt_simple.mount_path
}

output "auth_jwt_mount_path" {
  value = module.auth_jwt.mount_path
}

output "auth_jwt_role_name" {
  value = module.auth_jwt.role_name
}

###################################################### Userpass:
output "auth_userpass_simple_mount_path" {
  value = module.auth_userpass_simple.mount_path
}

output "auth_userpass_simple_initial_passwords" {
  value     = module.auth_userpass_simple.initial_passwords
  sensitive = true
}

output "auth_userpass_mount_path" {
  value = module.auth_userpass.mount_path
}

output "auth_userpass_usernames" {
  value = module.auth_userpass.usernames
}

output "auth_userpass_initial_passwords" {
  value     = module.auth_userpass.initial_passwords
  sensitive = true
}

###################################################### Transit:
output "transit_simple_mount_path" {
  value = module.transit_simple.transit_mount_path
}

output "transit_simple_token" {
  value     = module.transit_simple.transit_token_value
  sensitive = true
}

output "transit_mount_path" {
  value = module.transit.transit_mount_path
}

output "transit_key_name" {
  value = module.transit.transit_key_name
}

output "transit_token" {
  value     = module.transit.transit_token_value
  sensitive = true
}

###################################################### Identity Entity:
output "entity_alice_id" {
  value = module.entity_alice.entity_id
}

output "entity_bob_id" {
  value = module.entity_bob.entity_id
}

###################################################### Identity Group:
output "group_ops_id" {
  value = module.group_ops.group_id
}

###################################################### Identity OIDC:
output "oidc_simple_key_name" {
  value = module.oidc_simple.key_name
}

output "oidc_key_name" {
  value = module.oidc.key_name
}

output "oidc_role_client_ids" {
  value = module.oidc.role_client_ids
}

###################################################### Password Policies:
output "password_policy_simple_name" {
  value = module.password_policy_simple.policy_name
}

output "password_policy_ops_name" {
  value = module.password_policy_ops.policy_name
}

output "password_policy_service_name" {
  value = module.password_policy_service.policy_name
}
