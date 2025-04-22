resource "vault_jwt_auth_backend" "oidc" {
  description        = "OIDC backend"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://auth.sims.family"
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = var.oidc_client_secret
  bound_issuer       = "https://auth.sims.family"
  default_role       = "admins"
  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "oidc_role" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "admins"
  token_policies = ["default", "admins"]

  user_claim            = "name"
  role_type             = "oidc"
  oidc_scopes           = ["profile"]
  allowed_redirect_uris = ["https://vault.deep-thonk.com/ui/vault/auth/oidc/oidc/callback"]
}
