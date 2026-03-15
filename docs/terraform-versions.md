---
layout: default
title: Terraform Versions
nav_order: 8
---

# Terraform Version History – Quick Reference

Key features and code examples for every major Terraform release from **v1.0 to v1.14**.

> **Latest stable release: v1.14.7** — March 11, 2026

**Path:** `terraform-versions/`

---

## Version Summary

| Version | Release | Must-Know Feature |
|---------|---------|------------------|
| [v1.0](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.0/CHANGELOG.md) | Jun 2021 | Stable API guarantee |
| [v1.1](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.1/CHANGELOG.md) | Dec 2021 | `moved` block, `cloud` backend |
| [v1.2](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.2/CHANGELOG.md) | May 2022 | `precondition`/`postcondition` |
| [v1.3](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.3/CHANGELOG.md) | Sep 2022 | `optional()` in object types |
| [v1.4](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.4/CHANGELOG.md) | Mar 2023 | `import` block |
| [v1.5](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.5/CHANGELOG.md) | Jun 2023 | `import` GA, `check` block |
| [v1.6](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.6/CHANGELOG.md) | Oct 2023 | `terraform test` GA |
| [v1.7](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.7/CHANGELOG.md) | Jan 2024 | `mock_provider`, `removed` block |
| [v1.8](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.8/CHANGELOG.md) | Apr 2024 | Provider-defined functions |
| [v1.9](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.9/CHANGELOG.md) | Jun 2024 | Cross-variable validation |
| [v1.10](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.10/CHANGELOG.md) | Nov 2024 | Ephemeral resources (experimental), `write_only` attributes |
| [v1.11](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.11/CHANGELOG.md) | Feb 2025 | Ephemeral resources GA, `provider for_each` (experimental) |
| [v1.12](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.12/CHANGELOG.md) | May 2025 | `provider for_each` GA, Stacks enhancements |
| [v1.13](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.13/CHANGELOG.md) | Sep 2025 | Enhanced module iteration, `strcontains`/`strtitle` functions |
| [**v1.14.7**](https://github.com/chefgs/terraform_repo/blob/main/terraform-versions/v1.14/CHANGELOG.md) | **Mar 11, 2026** | Deferred changes GA, test setup/teardown, auto lock file platforms |

---

## Key Feature Highlights

### moved Block (v1.1)
Rename or reorganize resources without destroying them:
```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.web_server
}
```

### Preconditions (v1.2)
Add runtime assertions to resources:
```hcl
lifecycle {
  precondition {
    condition     = var.instance_count > 0
    error_message = "instance_count must be positive"
  }
}
```

### Optional Object Attributes (v1.3)
```hcl
variable "config" {
  type = object({
    required_field = string
    optional_field = optional(string, "default_value")
  })
}
```

### import Block (v1.4/v1.5)
Declaratively import existing resources:
```hcl
import {
  id = "vpc-12345678"
  to = aws_vpc.main
}
```

### terraform test (v1.6)
```bash
terraform test                    # Run all tests
terraform test -filter=vpc.tftest # Run specific test
```

### mock_provider (v1.7)
Unit test without real infrastructure:
```hcl
mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = { id = "vpc-mock123" }
  }
}
```

### Ephemeral Resources (v1.10 experimental → v1.11 GA)
Secrets that are never written to state:
```hcl
ephemeral "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}
```

### provider for_each (v1.11 experimental → v1.12 GA)
Manage resources across multiple accounts/regions:
```hcl
provider "aws" {
  for_each = var.regions
  alias    = each.key
  region   = each.key
}
```

### Deferred Changes (v1.14 GA)
Plan and apply in phases when values are unknown until runtime:
```bash
terraform apply   # first pass: creates known resources, defers unknowns
terraform apply   # second pass: resolves deferred resources
```

---

## Version Management

```bash
# Install latest stable version with tfenv
tfenv install 1.14.7 && tfenv use 1.14.7

# Or with asdf
asdf install terraform 1.14.7 && asdf global terraform 1.14.7

# Install a specific older version
tfenv install 1.9.0 && tfenv use 1.9.0

# Check current version
terraform version
```

---

## Related

- [IaC Best Practices](./iac-best-practices)
- [AWS Samples](./aws-samples)
