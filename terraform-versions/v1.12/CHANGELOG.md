# Terraform v1.12 – `for_each` on Provider Blocks GA & Stack Enhancements (May 2025)

## What's New

### 1. `provider for_each` – Generally Available

The experimental `provider for_each` feature from v1.11 is now **GA**. Manage resources across multiple cloud accounts, regions, or environments with a single module:

```hcl
terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

# Multi-region provider configuration
variable "regions" {
  type    = set(string)
  default = ["us-east-1", "us-west-2", "eu-west-1"]
}

provider "aws" {
  for_each = var.regions
  alias    = each.key
  region   = each.key
}

# Deploy identical infrastructure to every region
resource "aws_vpc" "regional" {
  for_each   = var.regions
  provider   = aws[each.key]
  cidr_block = "10.0.0.0/16"

  tags = {
    Name   = "vpc-${each.key}"
    Region = each.key
  }
}

# Module using a specific provider instance
module "compute" {
  for_each = var.regions
  source   = "./modules/compute"
  providers = {
    aws = aws[each.key]
  }
  region = each.key
}
```

### 2. Stacks Configuration – Enhanced Module Orchestration

Terraform Stacks (`*.tfstack.hcl`) improvements for composing multi-component deployments:

```hcl
# infrastructure.tfstack.hcl

# Declare required variables for the stack
variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Stack components
component "networking" {
  source  = "./components/networking"
  version = "~> 2.0"

  inputs = {
    environment = var.environment
    region      = var.aws_region
  }
}

component "database" {
  source = "./components/database"

  inputs = {
    environment = var.environment
    vpc_id      = component.networking.outputs.vpc_id
    subnet_ids  = component.networking.outputs.private_subnet_ids
  }
}

component "application" {
  source = "./components/application"

  inputs = {
    environment = var.environment
    vpc_id      = component.networking.outputs.vpc_id
    db_endpoint = component.database.outputs.endpoint
  }
}
```

### 3. Improved Plan Output for `for_each` Resources

```bash
$ terraform plan

# Before v1.12: individual resource lines per instance
# After v1.12: grouped summary for large for_each maps

# will create 50 resources
# aws_s3_bucket.regional["ap-northeast-1"] + 49 more

Plan: 50 to add, 0 to change, 0 to destroy.
```

### 4. New `coalesce` Improvements

```hcl
locals {
  # coalesce now short-circuits on first non-null, non-empty value
  # and handles mixed types more gracefully
  region = coalesce(
    var.override_region,      # null if not set
    local.default_region,     # "" if not configured
    "us-east-1"               # fallback
  )
}
```

## Upgrade from v1.11

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.12"
}
```
