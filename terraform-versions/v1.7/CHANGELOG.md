# Terraform v1.7 – mock_provider & removed Block (January 2024)

## What's New

### 1. `mock_provider` – Unit Testing Without Real Infrastructure

Test modules without creating actual cloud resources:

```hcl
# tests/unit/vpc_mock.tftest.hcl

mock_provider "aws" {
  # Override specific resource defaults
  mock_resource "aws_vpc" {
    defaults = {
      id         = "vpc-mockabc123"
      arn        = "arn:aws:ec2:us-east-1:000000000000:vpc/vpc-mockabc123"
      cidr_block = "10.0.0.0/16"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id                = "subnet-mock123"
      availability_zone = "us-east-1a"
      cidr_block        = "10.0.1.0/24"
    }
  }

  # Override data source responses
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }
}

run "test_vpc_outputs" {
  command = plan

  variables {
    name       = "mock-vpc"
    cidr_block = "10.0.0.0/16"
  }

  assert {
    condition     = output.vpc_id == "vpc-mockabc123"
    error_message = "vpc_id output should return mocked VPC ID"
  }
}
```

**Benefits of mock_provider:**
- Tests run instantly (no AWS API calls)
- No cost for test resources
- Tests can run without AWS credentials
- Deterministic results

### 2. `removed` Block – Safely Remove Resources from State

Remove a resource from Terraform management **without destroying it**:

```hcl
# Resource was manually deleted or should no longer be managed by Terraform
removed {
  from = aws_security_group.legacy

  lifecycle {
    destroy = false  # Don't destroy, just remove from state
  }
}

# Remove an entire module
removed {
  from = module.old_logging

  lifecycle {
    destroy = false
  }
}
```

**This is the opposite of `import`:**
- `import` → bring existing resource under Terraform management
- `removed` → take resource out of Terraform management

### 3. `terraform test` Improvements

```hcl
# Test variables file support
run "test_with_var_file" {
  command = plan

  # Load variables from a file
  variables {
    # inline overrides
  }

  # module-level assertions
  assert {
    condition     = module.vpc.vpc_id != ""
    error_message = "VPC module should output a VPC ID"
  }
}
```

## Upgrade from v1.6

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.7"
}
```
