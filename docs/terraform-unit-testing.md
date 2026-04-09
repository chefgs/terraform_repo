---
layout: default
title: Terraform Unit Testing Guide
nav_order: 8
---

# How to Do Unit Testing for HashiCorp Terraform Code

This guide explains how to write and run **unit tests for Terraform modules** using the native `terraform test` framework and `mock_provider`.

---

## What “Unit Testing” Means in Terraform

Terraform unit tests verify module behavior without creating real cloud resources:

- Run with `command = plan`
- Use `mock_provider` to avoid real API calls
- Assert expected values, counts, and guardrails

This repository includes real examples in:

- `iac-best-practices/testing/vpc_unit.tftest.hcl`
- `iac-best-practices/testing/sg_unit.tftest.hcl`
- `nvidia/terraform/tests/*.tftest.hcl`

---

## Prerequisites

- Terraform CLI (1.7+ recommended for `mock_provider`)
- A module under test
- One or more `.tftest.hcl` files

---

## Recommended Test Layout

Use a layout like:

```text
iac-best-practices/
├── modules/
│   ├── vpc/
│   ├── security-group/
│   └── root-example/
└── testing/
    ├── vpc_unit.tftest.hcl
    └── sg_unit.tftest.hcl
```

Keep tests close to modules (same folder) or in a dedicated `testing/` directory.

---

## Step-by-Step: Create a Unit Test

### 1) Create a test file

Create `<name>_unit.tftest.hcl` (for example `vpc_unit.tftest.hcl`).

### 2) Mock provider resources

Use `mock_provider` so tests run offline and safely:

```hcl
mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id         = "vpc-mock12345678"
      cidr_block = "10.0.0.0/16"
    }
  }
}
```

### 3) Add a `run` block using `plan`

```hcl
run "vpc_basic_creation" {
  command = plan

  variables {
    name                = "test-vpc"
    cidr_block          = "10.0.0.0/16"
    availability_zones  = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  }
}
```

### 4) Add assertions

Validate behavior, not implementation details:

```hcl
assert {
  condition     = aws_vpc.this.enable_dns_support == true
  error_message = "DNS support should be enabled on VPC"
}
```

### 5) Run tests

```bash
# From module root
terraform test

# Run one test file
terraform test -filter=../../testing/vpc_unit.tftest.hcl

# Verbose output
terraform test -verbose
```

---

## What to Test in Terraform Modules

For each module, cover:

1. **Happy path**  
   Valid inputs create the expected resources/values.
2. **Conditional logic**  
   `count`, `for_each`, and feature flags behave as intended.
3. **Defaults and optional values**  
   Defaults are safe and predictable.
4. **Validation and guardrails**  
   Invalid input fails with clear errors.
5. **Tag and naming conventions**  
   Required metadata is applied consistently.

---

## Unit vs Integration Tests

| Type | Command Pattern | Uses Real Cloud APIs | Typical Use |
|------|------------------|----------------------|-------------|
| Unit | `command = plan` + `mock_provider` | No | Fast logic verification |
| Integration | `command = apply` | Yes | End-to-end environment checks |

Use unit tests for most PR checks, and integration tests in controlled environments.

---

## CI/CD Usage Pattern

Recommended pipeline order:

1. `terraform fmt -check`
2. `terraform init -backend=false`
3. `terraform validate`
4. `terraform test -verbose`

If your tests rely on mocks only, no cloud credentials are required.

---

## Common Issues and Fixes

- **`terraform: command not found`**  
  Install Terraform CLI in local/CI runtime.
- **Path/filter problems**  
  Run from the correct working directory or use full relative paths.
- **Assertions too brittle**  
  Assert important behavior (counts, key attributes), not every computed field.

---

## Repository References

- [IaC Best Practices Overview](./iac-best-practices.md)
- `iac-best-practices/testing/README.md`
- `nvidia/terraform/tests/`

