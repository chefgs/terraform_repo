# IaC Best Practices – Terraform Testing

Native Terraform testing using the `terraform test` command (GA in Terraform 1.6+).

## Test Types

| Type | File Extension | Description |
|------|---------------|-------------|
| Unit | `.tftest.hcl` | Test modules in isolation with mock providers |
| Integration | `.tftest.hcl` | Test with real providers (creates actual resources) |

## Files

| File | Tests |
|------|-------|
| `vpc_unit.tftest.hcl` | VPC module unit tests with mock provider |
| `sg_unit.tftest.hcl` | Security group unit tests |
| `integration.tftest.hcl` | Integration test (creates real AWS resources) |

## Run Tests

```bash
# Run all tests
terraform test

# Run specific test file
terraform test -filter=vpc_unit.tftest.hcl

# Run with verbose output
terraform test -verbose

# Run integration tests only
terraform test -filter=integration.tftest.hcl
```

## Test Structure

```hcl
# Example test structure
run "test_name" {
  command = plan  # or apply

  variables {
    # Override variables for this test
  }

  assert {
    condition     = <expression>
    error_message = "Descriptive failure message"
  }
}
```

## Mock Providers (Terraform 1.7+)

Use `mock_provider` to test without real infrastructure:

```hcl
mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id         = "vpc-mock12345"
      cidr_block = "10.0.0.0/16"
    }
  }
}
```
