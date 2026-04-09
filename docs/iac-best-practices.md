---
layout: default
title: IaC Best Practices
nav_order: 7
---

# IaC Best Practices – Terraform

A comprehensive reference for enterprise-grade Terraform usage covering modular design, variable templatization, native testing, and lock file management.

**Path:** `iac-best-practices/`

---

## Modular Resource Creation

**Path:** `iac-best-practices/modules/`

Standard module structure with VPC, Security Group, and a root composition example.

### Module Design Principles

```
modules/
├── vpc/              # VPC + subnets + IGW + NAT + route tables
├── security-group/   # SG with dynamic ingress/egress rules
└── root-example/     # Root module composing child modules
```

### Example: Module Composition

```hcl
module "vpc" {
  source = "../vpc"
  name   = "prod-vpc"
  cidr_block = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  enable_nat_gateway   = true
}

module "app_sg" {
  source = "../security-group"
  name   = "app-sg"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.web_sg.security_group_id]
  }]
}
```

---

## Variable Templatization

**Path:** `iac-best-practices/variables/`

Comprehensive variable patterns covering all Terraform types.

### Key Patterns

**Validation blocks:**
```hcl
variable "environment" {
  type    = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}
```

**Optional object attributes (Terraform 1.3+):**
```hcl
variable "scaling_config" {
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = optional(number)
    cooldown_seconds = optional(number, 300)
  })
}
```

**Environment-specific tfvars:**
```bash
terraform plan -var-file="environments/prod.tfvars"
```

---

## Terraform Native Testing

**Path:** `iac-best-practices/testing/`

Write tests using `.tftest.hcl` files (Terraform 1.6+ GA).

### Unit Test with Mock Provider (Terraform 1.7+)

```hcl
mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = { id = "vpc-mock123" }
  }
}

run "test_vpc" {
  command = plan
  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "DNS support must be enabled"
  }
}
```

**Run tests:**
```bash
cd iac-best-practices/modules/
terraform test -filter=../testing/vpc_unit.tftest.hcl
```

For a full step-by-step unit testing guide, see:

- [Terraform Unit Testing Guide](./terraform-unit-testing.html)

---

## Lock File Management

**Path:** `iac-best-practices/lock-file-management/`

### Rules

1. ✅ **Always commit** `.terraform.lock.hcl` to version control
2. ✅ **Lock for all platforms** used by your team and CI/CD
3. ❌ **Never manually edit** the lock file
4. ✅ **Use `terraform init -upgrade`** to update provider versions

### Multi-Platform Lock

```bash
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_arm64 \
  -platform=windows_amd64
```

---

## Related

- [Terraform Versions](./terraform-versions.html)
- [AWS Samples](./aws-samples.html)
