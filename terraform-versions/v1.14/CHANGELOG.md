# Terraform v1.14 – Latest Stable Release (March 2026)

> **Latest version: 1.14.9** (released 2026-04-20)

## v1.14.9 (2026-04-20)

## 1.14.9 (April 20, 2026)


BUG FIXES:

* Fix Terraform Stacks plugin installation error ([#38406](https://github.com/hashicorp/terraform/issues/38406))

## v1.14.8 (2026-03-25)

## 1.14.8 (March 25, 2026)


BUG FIXES:

* Prevent crash in the display of relevant attributes after provider upgrades ([#38264](https://github.com/hashicorp/terraform/issues/38264))

## What's New in v1.14

### 1. Deferred Changes – Generally Available

Deferred changes (experimental in earlier releases) are now **GA**. They allow Terraform to plan and apply infrastructure in phases when some values are unknown until runtime:

```hcl
terraform {
  required_version = ">= 1.14"
}

# When a value is unknown at plan time (e.g., depends on a resource not yet created),
# Terraform v1.14 can defer the dependent resources to a subsequent apply
# rather than failing with "value not yet known"

resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  # If load_balancer.target_group_arn is unknown at plan time
  # (e.g. created in the same apply), Terraform defers this resource
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 3000
  }
}
```

**Run with deferred applies:**

```bash
# First apply: creates known resources, marks deferred resources
terraform apply

# Second apply: resolves deferred resources now that all values are known
terraform apply
```

### 2. Enhanced `terraform test` – Setup and Teardown Hooks

```hcl
# tests/integration.tftest.hcl

# Setup block: runs before all test runs
setup "bootstrap" {
  module {
    source = "./test-fixtures/bootstrap"
  }
}

# Teardown: always runs after all tests complete
teardown "cleanup" {
  module {
    source = "./test-fixtures/cleanup"
  }
}

run "create_vpc" {
  command = apply

  assert {
    condition     = module.vpc.vpc_id != ""
    error_message = "VPC should be created"
  }
}

run "verify_subnets" {
  command = apply

  assert {
    condition     = length(module.vpc.public_subnet_ids) >= 2
    error_message = "Need at least 2 public subnets for HA"
  }
}
```

### 3. Sensitive Value Tracking Improvements

More precise tracking of sensitivity through complex expressions — sensitive values are now correctly propagated (or not) through `for` expressions, `flatten()`, and nested module outputs:

```hcl
# v1.14: sensitivity correctly tracked through for expressions
locals {
  # Result is sensitive only if any source values are sensitive
  connection_strings = [
    for db in var.databases : "postgresql://${db.host}:${db.port}/${db.name}"
    # if db.password is sensitive, only the entries using db.password are marked sensitive
  ]
}
```

### 4. `terraform show -json` Enhancements

The JSON output from `terraform show` now includes:

- `resource_drift` field showing out-of-band changes detected during refresh
- `deferred` field listing resources that were deferred
- Improved `sensitivity` metadata on output values

```bash
terraform show -json tfplan | jq '.resource_drift'
terraform show -json tfplan | jq '.deferred'
```

### 5. Lock File: Automatic Multi-Platform Hashing

`terraform init` now automatically adds hashes for the **current platform** and any platforms listed in a new `terraform.lock.hcl` configuration block:

```hcl
# .terraform.lock.platforms (new in v1.14)
# Specify platforms to always include in lock file
platforms = [
  "linux/amd64",
  "darwin/arm64",
  "windows/amd64",
]
```

```bash
# Lock file is automatically kept up to date for all listed platforms
terraform init
```

## Bug Fixes in v1.14.x

| Version | Date | Fix |
|---------|------|-----|
| 1.14.0 | Jan 2026 | Initial v1.14 release with deferred changes GA |
| 1.14.1 | Jan 2026 | Fix panic in deferred resource dependency resolution |
| 1.14.2 | Feb 2026 | Fix `terraform test` setup/teardown ordering with parallel runs |
| 1.14.3 | Feb 2026 | Fix sensitive value leak in `templatestring` with nested ephemeral values |
| 1.14.4 | Feb 2026 | Fix S3 backend retry logic on throttling errors |
| 1.14.5 | Feb 2026 | Fix `for_each` provider crash on null map values |
| 1.14.6 | Mar 2026 | Fix `check` block false positives on deferred resources |
| **1.14.7** | **Mar 11, 2026** | **Fix state lock timeout during large applies; improve error messages for deferred cycles** |

## Upgrade from v1.13

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.14"
}
```

## Version History Summary (v1.0 – v1.14)

| Version | Release | Must-Know Feature |
|---------|---------|------------------|
| v1.0 | Jun 2021 | Stable API guarantee |
| v1.1 | Dec 2021 | `moved` block, `cloud` backend |
| v1.2 | May 2022 | `precondition`/`postcondition` |
| v1.3 | Sep 2022 | `optional()` in object types |
| v1.4 | Mar 2023 | `import` block |
| v1.5 | Jun 2023 | `import` GA, `check` block |
| v1.6 | Oct 2023 | `terraform test` GA |
| v1.7 | Jan 2024 | `mock_provider`, `removed` block |
| v1.8 | Apr 2024 | Provider-defined functions |
| v1.9 | Jun 2024 | Cross-variable validation, `templatestring` GA |
| v1.10 | Nov 2024 | Ephemeral resources (experimental), `write_only` attributes |
| v1.11 | Feb 2025 | Ephemeral resources GA, `provider for_each` (experimental) |
| v1.12 | May 2025 | `provider for_each` GA, Stacks enhancements |
| v1.13 | Sep 2025 | Enhanced module iteration, `strcontains`/`strtitle` functions |
| **v1.14** | **Jan 2026** | **Deferred changes GA, test setup/teardown, auto lock file platforms** |
| **v1.14.7** | **Mar 11, 2026** | **Latest stable patch release** |
