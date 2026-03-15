# Terraform v1.5 – import Block GA, check Block (June 2023)

## What's New

### 1. `import` Block – Generally Available

The `import` block introduced in v1.4 is now GA (no longer experimental):

```hcl
import {
  id = "i-1234567890abcdef0"
  to = aws_instance.example
}
```

### 2. `check` Block – Continuous Validation

The `check` block validates infrastructure state **outside** the normal plan/apply lifecycle. Failures are warnings (not errors) so they don't block deployments:

```hcl
# Check that a URL is accessible (runs after apply)
check "website_accessible" {
  data "http" "app_health" {
    url = "https://${aws_lb.app.dns_name}/health"
  }

  assert {
    condition     = data.http.app_health.status_code == 200
    error_message = "Application health check returned ${data.http.app_health.status_code}, expected 200"
  }
}

# Check that an S3 bucket has versioning enabled
check "s3_versioning" {
  data "aws_s3_bucket" "app" {
    bucket = aws_s3_bucket.app.id
  }

  assert {
    condition     = data.aws_s3_bucket.app.versioning[0].enabled == true
    error_message = "S3 bucket versioning should be enabled"
  }
}
```

### 3. `import` Block with `for_each`

```hcl
locals {
  subnets = {
    "subnet-public-1"  = "subnet-aaaa1111"
    "subnet-public-2"  = "subnet-bbbb2222"
    "subnet-private-1" = "subnet-cccc3333"
  }
}

import {
  for_each = local.subnets
  id       = each.value
  to       = aws_subnet.this[each.key]
}

resource "aws_subnet" "this" {
  for_each = local.subnets
  # ...
}
```

### 4. `terraform plan -generate-config-out`

Auto-generate resource configurations for imports:

```bash
# Import block defined, but no resource block yet
import {
  id = "vpc-12345678"
  to = aws_vpc.imported
}

# Generate the resource config automatically
terraform plan -generate-config-out=generated.tf
# Creates generated.tf with all vpc attributes filled in
```

## Upgrade from v1.4

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.5"
}
```
