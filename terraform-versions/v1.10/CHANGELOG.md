# Terraform v1.10 – Ephemeral Resources (November 2024)

## What's New

### 1. Ephemeral Resources (Experimental)

Ephemeral resources are a new resource kind whose values exist only **in memory during a Terraform run** — they are never written to state or to plan files. This is ideal for short-lived secrets, one-time tokens, and dynamic credentials:

```hcl
# Ephemeral resource – value is NEVER stored in state
ephemeral "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "main" {
  identifier = "prod-db"
  password   = ephemeral.aws_secretsmanager_secret_version.db_password.secret_string
  # ...
}
```

**Supported built-in ephemeral types (v1.10):**
- `ephemeral "random_password"` — generate passwords that never touch state
- `ephemeral "tls_private_key"` — private keys that stay in memory only

### 2. `write_only` Attribute Schema

Provider authors can mark resource attributes as `write_only`, meaning the value is accepted on write (create/update) but never stored in state or returned on read. This prevents secrets from appearing in `terraform show`:

```hcl
# Provider definition (for provider developers)
resource "example_database" "main" {
  username = "admin"
  password = var.db_password  # marked write_only in provider schema
  # 'password' will NOT appear in state file
}
```

### 3. Ephemeral Values in `output`

Outputs can now be marked ephemeral, preventing their values from being stored in state:

```hcl
output "db_connection_string" {
  value     = "postgresql://${var.db_user}:${ephemeral.random_password.db.result}@${aws_db_instance.main.endpoint}/app"
  ephemeral = true  # never stored in state
  sensitive = true  # also redacted from CLI output
}
```

### 4. New `ephemeralasnull` Function

Convert ephemeral values to `null` for use in contexts that don't support ephemeral values:

```hcl
locals {
  # Needed when passing ephemeral value to a resource attribute
  # that doesn't support ephemeral inputs
  safe_password = ephemeralasnull(ephemeral.random_password.db.result)
}
```

## Upgrade from v1.9

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.10"
}
```

> **Note:** Ephemeral resources require provider support. Check provider changelogs for `ephemeral` resource type support.
