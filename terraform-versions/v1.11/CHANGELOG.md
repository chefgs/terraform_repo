# Terraform v1.11 – Ephemeral Resources GA & Provider Iteration (February 2025)

## What's New

### 1. Ephemeral Resources – Generally Available

Ephemeral resources introduced experimentally in v1.10 are now **GA** (no longer gated behind an experimental flag). They are a first-class resource type:

```hcl
terraform {
  required_version = ">= 1.11"
}

# GA: no experimental flag needed
ephemeral "aws_secretsmanager_secret_version" "api_key" {
  secret_id = aws_secretsmanager_secret.api_key.id
}

resource "kubernetes_secret" "app" {
  metadata { name = "app-secrets" }
  data = {
    api_key = ephemeral.aws_secretsmanager_secret_version.api_key.secret_string
  }
}
```

**Built-in ephemeral resources (GA in v1.11):**

| Resource | Description |
|----------|-------------|
| `ephemeral "random_password"` | Random password, never stored in state |
| `ephemeral "tls_private_key"` | TLS private key, never stored in state |
| `ephemeral "aws_secretsmanager_secret_version"` | AWS secret value |
| `ephemeral "vault_generic_secret"` | Vault KV secret |

### 2. `provider` Meta-Argument with `for_each` (Experimental)

Iterate over provider configurations using `for_each` on `provider` blocks — useful for managing resources across multiple accounts or regions:

```hcl
# Define multiple AWS provider instances via for_each
variable "aws_regions" {
  type    = set(string)
  default = ["us-east-1", "eu-west-1", "ap-southeast-1"]
}

provider "aws" {
  for_each = var.aws_regions
  alias    = each.key
  region   = each.key
}

# Create an S3 bucket in each region
resource "aws_s3_bucket" "backups" {
  for_each = var.aws_regions
  provider = aws[each.key]
  bucket   = "backups-${each.key}-${random_id.suffix.hex}"
}
```

> **Note:** `provider for_each` is still experimental in v1.11. Enable with `experiments = [provider_for_each]` inside the `terraform` block.

### 3. Improved `terraform test` – `expect_failures` for Known Errors

```hcl
run "test_invalid_input" {
  command = plan

  variables {
    instance_count = -1  # Invalid – should trigger validation error
  }

  # Assert that specific errors are expected
  expect_failures = [
    var.instance_count,
  ]
}
```

### 4. `templatefile` now supports Recursive Templates

```hcl
# Nested template rendering
locals {
  config = templatefile("${path.module}/templates/config.json.tpl", {
    db_host  = module.rds.endpoint
    app_name = var.app_name
    # Can now reference other templatefile() calls
    tls_config = templatefile("${path.module}/templates/tls.json.tpl", {
      cert_arn = aws_acm_certificate.app.arn
    })
  })
}
```

## Upgrade from v1.10

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.11"
}
```
