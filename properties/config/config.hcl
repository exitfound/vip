ui = true
disable_mlock = true
max_lease_ttl = "768h"
default_lease_ttl = "24h"

storage "file" {
 path   = "/opt/vault/data"
}

listener "tcp" {
 address = "0.0.0.0:8200"
 tls_disable = "true"
}

# Only with SSL for your Vault
# listener "tcp" {
#  address = "0.0.0.0:443"
#  tls_cert_file = "/etc/letsencrypt/live/your_domain/fullchain.pem"
#  tls_key_file = "/etc/letsencrypt/live/your_domain/privkey.pem"
#  tls_disable = "false"
# }