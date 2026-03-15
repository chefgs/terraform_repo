# Terraform v1.8 – Provider-Defined Functions (April 2024)

## What's New

### 1. Provider-Defined Functions

Providers can now expose **custom functions** callable from Terraform configuration. This enables complex transformations without external data sources:

```hcl
# AWS provider example (hypothetical, check provider docs for actual functions)

# Call a provider-defined function
locals {
  # providers expose functions in the format: provider::<name>(<args>)
  parsed_arn = provider::aws::arn_parse(var.resource_arn)
  account_id = local.parsed_arn.account_id
  region     = local.parsed_arn.region
}

# The AWS provider exposes arn_parse function
output "arn_components" {
  value = {
    partition = local.parsed_arn.partition
    service   = local.parsed_arn.service
    region    = local.parsed_arn.region
    account   = local.parsed_arn.account_id
    resource  = local.parsed_arn.resource
  }
}
```

### 2. Calling Provider Functions Directly

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"  # Must support provider functions
    }
  }
}

# Example: AWS provider arn_parse
data "aws_arn" "example" {
  arn = "arn:aws:iam::123456789012:role/MyRole"
}

# With provider function (v1.8+):
locals {
  role_name = provider::aws::arn_parse("arn:aws:iam::123456789012:role/MyRole").resource
}
```

### 3. `templatestring` Function Preview

```hcl
locals {
  template = "Hello, $${name}! You are in $${region}."

  rendered = templatestring(local.template, {
    name   = var.user_name
    region = var.aws_region
  })
}
```

### 4. Stacks Configuration (Preview)

Terraform Stacks (HCP Terraform feature) allows composing multiple components:

```hcl
# stack.tfstack.hcl
component "networking" {
  source = "./networking"

  inputs = {
    region = var.region
  }
}

component "compute" {
  source = "./compute"

  inputs = {
    vpc_id = component.networking.outputs.vpc_id
    region = var.region
  }
}
```

## Upgrade from v1.7

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.8"
}
```
