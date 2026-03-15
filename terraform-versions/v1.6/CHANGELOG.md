# Terraform v1.6 – terraform test GA (October 2023)

## What's New

### 1. `terraform test` – Generally Available

Native Terraform testing framework is GA. Write tests in `.tftest.hcl` files:

```hcl
# tests/vpc.tftest.hcl
run "basic_vpc_test" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
    name     = "test-vpc"
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should match input"
  }
}

run "apply_and_verify" {
  command = apply  # Actually creates resources

  variables {
    vpc_cidr = "172.16.0.0/16"
    name     = "integration-test-vpc"
  }

  assert {
    condition     = aws_vpc.this.id != ""
    error_message = "VPC ID should be set after apply"
  }
}
```

**Test commands:**
```bash
# Run all tests
terraform test

# Run specific file
terraform test -filter=tests/vpc.tftest.hcl

# Verbose output
terraform test -verbose
```

### 2. S3 Backend Enhancements

```hcl
terraform {
  backend "s3" {
    bucket = "my-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"

    # v1.6: use_path_style for custom S3-compatible endpoints (MinIO etc.)
    use_path_style = true
    endpoints = {
      s3       = "https://minio.example.com"
      iam      = "https://minio.example.com"
      sts      = "https://minio.example.com"
    }
  }
}
```

### 3. OPA/Sentinel Policy Integration (HCP Terraform)

For HCP Terraform (formerly TFC):
```
Workspace Settings → Policies → Add OPA Policy Set
```

```rego
# example_policy.rego
package terraform

import rego.v1

deny contains msg if {
  some resource in input.resource_changes
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  msg := sprintf("S3 bucket %v must have encryption enabled", [resource.address])
}
```

### 4. New Functions

```hcl
locals {
  # issensitive() – check if a value is marked sensitive
  is_secret = issensitive(var.db_password)

  # nonsensitive() – remove sensitive marking (use carefully!)
  debug_value = nonsensitive(var.db_password)
}
```

## Upgrade from v1.5

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.6"
}
```
