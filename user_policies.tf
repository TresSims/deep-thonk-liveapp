resource "vault_policy" "admin_policy" {
  name = "admins"
  
  policy = file("policies/admin_policy.hcl")
}
