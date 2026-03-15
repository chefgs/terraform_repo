##############################################################################
# Vault – Secrets Management for 2-Tier AWS Application
#
# This configuration sets up:
#   1. AWS IAM Auth method (instances authenticate using AWS metadata)
#   2. KV secrets engine (v2) for application configuration
#   3. Database secrets engine with dynamic PostgreSQL credentials
#   4. PKI secrets engine for internal TLS certificates
#   5. Policies for web-tier and app-tier roles
##############################################################################

# ── KV Secrets Engine (v2) ────────────────────────────────────────────────
resource "vault_mount" "kv" {
  path    = "secret"
  type    = "kv"
  options = { version = "2" }
  description = "KV v2 secrets engine for application configuration"
}

# Store application configuration secrets
resource "vault_kv_secret_v2" "app_config" {
  mount               = vault_mount.kv.path
  name                = "2tier-app/config"
  delete_all_versions = true

  data_json = jsonencode({
    db_host     = "rds.internal.example.com"
    db_name     = "appdb"
    redis_host  = "redis.internal.example.com"
    app_port    = "3000"
    log_level   = "info"
  })
}

# ── Database Secrets Engine ────────────────────────────────────────────────
resource "vault_mount" "db" {
  path = "database"
  type = "database"
  description = "Dynamic database credentials for RDS PostgreSQL"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "app-postgres"
  allowed_roles = ["app-server-role", "readonly-role"]

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@${var.rds_endpoint}/appdb?sslmode=require"
    username       = var.db_admin_username
    password       = var.db_admin_password
  }
}

resource "vault_database_secret_backend_role" "app_server" {
  backend             = vault_mount.db.path
  name                = "app-server-role"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";",
  ]
  default_ttl = "1h"
  max_ttl     = "24h"
}

resource "vault_database_secret_backend_role" "readonly" {
  backend             = vault_mount.db.path
  name                = "readonly-role"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]
  default_ttl = "30m"
  max_ttl     = "4h"
}

# ── PKI Secrets Engine ────────────────────────────────────────────────────
resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "PKI secrets engine for internal TLS"
  default_lease_ttl_seconds = 86400    # 24h
  max_lease_ttl_seconds     = 31536000 # 1y
}

resource "vault_pki_secret_backend_root_cert" "ca" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "2tier-app Internal CA"
  ttl         = "87600h" # 10 years
  key_type    = "rsa"
  key_bits    = 4096
}

resource "vault_pki_secret_backend_role" "internal_tls" {
  backend          = vault_mount.pki.path
  name             = "internal-tls"
  ttl              = "8760h"   # 1 year
  max_ttl          = "17520h"  # 2 years
  allow_subdomains = true
  allowed_domains  = ["internal.example.com", "service.consul"]
  generate_lease   = true
}

# ── AWS IAM Auth Method ────────────────────────────────────────────────────
resource "vault_auth_backend" "aws" {
  type        = "aws"
  description = "AWS IAM authentication for EC2 instances"
}

resource "vault_aws_auth_backend_role" "web_tier" {
  backend                  = vault_auth_backend.aws.path
  role                     = "web-tier"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.web_instance.arn]
  token_policies           = [vault_policy.web_tier.name]
  token_ttl                = 3600
  token_max_ttl            = 86400
}

resource "vault_aws_auth_backend_role" "app_tier" {
  backend                  = vault_auth_backend.aws.path
  role                     = "app-tier"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.app_instance.arn]
  token_policies           = [vault_policy.app_tier.name]
  token_ttl                = 3600
  token_max_ttl            = 86400
}

# ── Vault Policies ────────────────────────────────────────────────────────
resource "vault_policy" "web_tier" {
  name   = "web-tier-policy"
  policy = <<-EOT
    # Web tier: Read Consul tokens, TLS certs only
    path "secret/data/2tier-app/config" {
      capabilities = ["read"]
    }
    path "pki/issue/internal-tls" {
      capabilities = ["create", "update"]
    }
    path "auth/token/renew-self" {
      capabilities = ["update"]
    }
  EOT
}

resource "vault_policy" "app_tier" {
  name   = "app-tier-policy"
  policy = <<-EOT
    # App tier: Read config, get dynamic DB creds, issue TLS certs
    path "secret/data/2tier-app/config" {
      capabilities = ["read"]
    }
    path "database/creds/app-server-role" {
      capabilities = ["read"]
    }
    path "pki/issue/internal-tls" {
      capabilities = ["create", "update"]
    }
    path "auth/token/renew-self" {
      capabilities = ["update"]
    }
  EOT
}

# ── AWS IAM Roles for EC2 Instances ───────────────────────────────────────
resource "aws_iam_role" "web_instance" {
  name = "${var.project_name}-web-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "app_instance" {
  name = "${var.project_name}-app-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Allow instances to call sts:GetCallerIdentity (Vault IAM auth)
resource "aws_iam_role_policy" "vault_iam_auth" {
  for_each = {
    web = aws_iam_role.web_instance.name
    app = aws_iam_role.app_instance.name
  }

  name = "${each.key}-vault-iam-auth"
  role = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sts:GetCallerIdentity"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.project_name}-web-instance-profile"
  role = aws_iam_role.web_instance.name
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app_instance.name
}
