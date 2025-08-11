ui                = true
disable_mlock     = true
max_lease_ttl     = "768h"
default_lease_ttl = "24h"

storage "file" {
  path            = "/opt/vault/data"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  tls_disable     = "true"
}
