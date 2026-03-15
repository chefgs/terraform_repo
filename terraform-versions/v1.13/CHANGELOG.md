# Terraform v1.13 – Enhanced Iteration & State Improvements (September 2025)

## What's New

### 1. `count` and `for_each` on Module Calls – Full Parity

Complete parity between `count`/`for_each` usage on resource blocks and module blocks, including:

- `count.index` and `each.key`/`each.value` fully supported in module `inputs`
- Better error messages for circular dependencies in iterated modules
- `module.<name>[*].outputs.<attr>` splat expressions on module outputs

```hcl
variable "environments" {
  type = map(object({
    region     = string
    min_size   = number
    max_size   = number
  }))
  default = {
    prod    = { region = "us-east-1", min_size = 3, max_size = 10 }
    staging = { region = "us-west-2", min_size = 1, max_size = 3  }
  }
}

module "app" {
  for_each = var.environments

  source = "./modules/app"

  environment = each.key
  region      = each.value.region
  min_size    = each.value.min_size
  max_size    = each.value.max_size
}

# Collect all ALB DNS names from every environment
output "all_alb_endpoints" {
  value = {
    for env, mod in module.app : env => mod.alb_dns_name
  }
}
```

### 2. State Move Improvements – Bulk Operations

```bash
# v1.13: terraform state mv now supports glob-style patterns
# Move all resources in a module to a new module path
terraform state mv \
  'module.old_name[*]' \
  'module.new_name'

# Interactive mode with confirmation prompt per resource
terraform state mv --interactive \
  'aws_instance.web[*]' \
  'module.compute.aws_instance.this'
```

### 3. `terraform plan -refresh=false` Improvements

More accurate diff display when using `-refresh=false`, with explicit warnings about potentially stale state:

```bash
terraform plan -refresh=false -out=tfplan

# Output now clearly marks:
# ⚠ Note: Refresh was skipped. State may not reflect actual infrastructure.
```

### 4. Expanded `check` Block Data Sources

The `check` block (introduced in v1.5) now supports more data sources including HTTP health checks with authentication headers:

```hcl
check "api_health" {
  data "http" "health_endpoint" {
    url = "https://${aws_lb.app.dns_name}/api/health"
    request_headers = {
      Authorization = "Bearer ${var.health_check_token}"
    }
  }

  assert {
    condition     = jsondecode(data.http.health_endpoint.response_body).status == "ok"
    error_message = "API health check failed: ${data.http.health_endpoint.response_body}"
  }
}
```

### 5. New String Functions

```hcl
locals {
  # strcontains() – check if a string contains a substring
  is_prod_bucket = strcontains(var.bucket_name, "-prod-")

  # strtitle() – convert string to title case
  display_name = strtitle(var.env_name)   # "production" → "Production"
}
```

## Upgrade from v1.12

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.13"
}
```
