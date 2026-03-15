---
layout: default
title: Terraform Versions
nav_order: 8
---

# Terraform Version History – Quick Reference

Key features and code examples for every major Terraform release from **v1.0 to v1.9**.

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

---

## Version Management

```bash
# Install specific version with tfenv
tfenv install 1.9.0 && tfenv use 1.9.0

# Or with asdf
asdf install terraform 1.9.0 && asdf global terraform 1.9.0

# Check current version
terraform version
```

---

## Related

- [IaC Best Practices](./iac-best-practices)
- [AWS Samples](./aws-samples)
