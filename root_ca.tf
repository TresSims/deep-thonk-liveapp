terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
  }

  required_version = "1.11.3"
}

provider "vault" {
  address = "https://vault.deep-thonk.com"
}

resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Vault root pki mount"

  default_lease_ttl_seconds   = 86400
  max_lease_ttl_seconds       = 315360000
  passthrough_request_headers = ["If-Modified-Since"]
  allowed_response_headers    = ["Last-Modified", "Location", "Replay-Nonce", "Link"]
}

resource "vault_pki_secret_backend_root_cert" "root_2025" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "deep-thonk.com"
  ttl         = 315360000
  issuer_name = "deep-thonk-vault-root"
}

resource "vault_pki_secret_backend_issuer" "root_2025" {
  backend                        = vault_mount.pki.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.root_2025.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.root_2025.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "2025-servers"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["deep-thonk.com", "sims.family"]
  allow_subdomains = true
  allow_any_name   = true
}

resource "vault_pki_secret_backend_config_urls" "pki-config-urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["http://localhost:8200/v1/pki/ca"]
  crl_distribution_points = ["http://localhost:8200/v1/pki/crl"]
  ocsp_servers            = ["http://localhost:8200/v1/pki/ocsp"]
  enable_templating       = true
}

resource "vault_pki_secret_backend_config_cluster" "pki-config-cluster" {
  backend  = vault_mount.pki.path
  path     = "http://localhost:8200/v1/pki"
  aia_path = "http://localhost:8200/v1/pki"
}

resource "vault_pki_secret_backend_config_acme" "root-acme" {
  backend                  = vault_mount.pki.path
  enabled                  = true
  allowed_issuers          = ["*"]
  allowed_roles            = ["*"]
  allow_role_ext_key_usage = false
  default_directory_policy = "sign-verbatim"
  dns_resolver             = ""
  eab_policy               = "not-required"
}
