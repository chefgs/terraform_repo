##############################################################################
# Boundary – Zero-Trust Access for 2-Tier AWS Application
#
# This configuration provisions:
#   1. Boundary Organizations and Projects
#   2. Auth methods (password + AWS IAM)
#   3. Host catalogs and host sets (dynamic via AWS tags)
#   4. Targets for web tier and app tier (SSH, HTTP)
#   5. Roles and grants for dev and ops teams
##############################################################################

# ── Organization ─────────────────────────────────────────────────────────
resource "boundary_scope" "org" {
  name                     = var.org_name
  description              = "Organization for ${var.project_name} infrastructure"
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# ── Projects ──────────────────────────────────────────────────────────────
resource "boundary_scope" "project_prod" {
  name                     = "${var.project_name}-production"
  description              = "Production 2-tier application access"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project_dev" {
  name                     = "${var.project_name}-development"
  description              = "Development environment access"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# ── Auth Method (Password) ────────────────────────────────────────────────
resource "boundary_auth_method" "password" {
  name        = "password-auth"
  description = "Username/password authentication"
  type        = "password"
  scope_id    = boundary_scope.org.id
}

# ── Users ─────────────────────────────────────────────────────────────────
resource "boundary_account_password" "dev_accounts" {
  for_each = var.dev_users

  auth_method_id = boundary_auth_method.password.id
  login_name     = each.value.login_name
  password       = each.value.password
  name           = each.value.name
}

resource "boundary_user" "dev_users" {
  for_each = var.dev_users

  name        = each.value.name
  description = "Developer: ${each.value.name}"
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.dev_accounts[each.key].id]
}

resource "boundary_account_password" "ops_accounts" {
  for_each = var.ops_users

  auth_method_id = boundary_auth_method.password.id
  login_name     = each.value.login_name
  password       = each.value.password
  name           = each.value.name
}

resource "boundary_user" "ops_users" {
  for_each = var.ops_users

  name        = each.value.name
  description = "Operations: ${each.value.name}"
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.ops_accounts[each.key].id]
}

# ── Groups ────────────────────────────────────────────────────────────────
resource "boundary_group" "developers" {
  name        = "developers"
  description = "Development team – read-only to app tier"
  scope_id    = boundary_scope.org.id
  member_ids  = [for u in boundary_user.dev_users : u.id]
}

resource "boundary_group" "operations" {
  name        = "operations"
  description = "Operations team – full access to all tiers"
  scope_id    = boundary_scope.org.id
  member_ids  = [for u in boundary_user.ops_users : u.id]
}

# ── Host Catalog (Dynamic – AWS Plugin) ───────────────────────────────────
resource "boundary_host_catalog_plugin" "aws_prod" {
  name            = "aws-prod-hosts"
  description     = "Dynamic AWS host catalog for production instances"
  scope_id        = boundary_scope.project_prod.id
  plugin_name     = "aws"

  attributes_json = jsonencode({
    region                      = var.aws_region
    disable_credential_rotation = false
  })

  secrets_json = jsonencode({
    access_key_id     = var.aws_access_key_id
    secret_access_key = var.aws_secret_access_key
  })
}

# ── Host Sets (filter by EC2 tag) ─────────────────────────────────────────
resource "boundary_host_set_plugin" "web_tier" {
  name            = "web-tier-hosts"
  description     = "Production web-tier instances"
  host_catalog_id = boundary_host_catalog_plugin.aws_prod.id

  attributes_json = jsonencode({
    filters = ["tag:Tier=web", "tag:Project=${var.project_name}"]
  })
}

resource "boundary_host_set_plugin" "app_tier" {
  name            = "app-tier-hosts"
  description     = "Production app-tier instances"
  host_catalog_id = boundary_host_catalog_plugin.aws_prod.id

  attributes_json = jsonencode({
    filters = ["tag:Tier=app", "tag:Project=${var.project_name}"]
  })
}

# ── SSH Credential Store (Vault-backed) ───────────────────────────────────
resource "boundary_credential_store_vault" "ssh_creds" {
  name        = "vault-ssh-store"
  description = "Vault-backed SSH credential store"
  address     = var.vault_address
  token       = var.vault_token
  scope_id    = boundary_scope.project_prod.id
}

resource "boundary_credential_library_vault_ssh_certificate" "web_ssh" {
  name                = "web-tier-ssh"
  description         = "SSH certificate for web-tier access"
  credential_store_id = boundary_credential_store_vault.ssh_creds.id
  path                = "ssh/sign/web-tier"
  username            = "ec2-user"
  key_type            = "ecdsa"
  key_bits            = 384
}

resource "boundary_credential_library_vault_ssh_certificate" "app_ssh" {
  name                = "app-tier-ssh"
  description         = "SSH certificate for app-tier access"
  credential_store_id = boundary_credential_store_vault.ssh_creds.id
  path                = "ssh/sign/app-tier"
  username            = "ec2-user"
  key_type            = "ecdsa"
  key_bits            = 384
}

# ── Targets ───────────────────────────────────────────────────────────────
resource "boundary_target" "web_ssh" {
  name         = "web-tier-ssh"
  description  = "SSH access to web-tier instances via Boundary"
  type         = "ssh"
  scope_id     = boundary_scope.project_prod.id
  default_port = "22"

  host_source_ids = [boundary_host_set_plugin.web_tier.id]
  injected_application_credential_source_ids = [
    boundary_credential_library_vault_ssh_certificate.web_ssh.id
  ]

  session_max_seconds        = 3600
  session_connection_limit   = 1
  enable_session_recording   = var.enable_session_recording
}

resource "boundary_target" "app_ssh" {
  name         = "app-tier-ssh"
  description  = "SSH access to app-tier instances via Boundary"
  type         = "ssh"
  scope_id     = boundary_scope.project_prod.id
  default_port = "22"

  host_source_ids = [boundary_host_set_plugin.app_tier.id]
  injected_application_credential_source_ids = [
    boundary_credential_library_vault_ssh_certificate.app_ssh.id
  ]

  session_max_seconds        = 3600
  session_connection_limit   = 1
  enable_session_recording   = var.enable_session_recording
}

# ── Roles & Grants ────────────────────────────────────────────────────────
resource "boundary_role" "dev_readonly" {
  name        = "dev-app-readonly"
  description = "Developers can only connect to app-tier"
  scope_id    = boundary_scope.project_prod.id
  principal_ids = [boundary_group.developers.id]

  grant_strings = [
    "ids=${boundary_target.app_ssh.id};actions=read,authorize-session",
  ]
}

resource "boundary_role" "ops_full_access" {
  name        = "ops-full-access"
  description = "Operations team has access to all tiers"
  scope_id    = boundary_scope.project_prod.id
  principal_ids = [boundary_group.operations.id]

  grant_strings = [
    "ids=${boundary_target.web_ssh.id};actions=read,authorize-session",
    "ids=${boundary_target.app_ssh.id};actions=read,authorize-session",
  ]
}
