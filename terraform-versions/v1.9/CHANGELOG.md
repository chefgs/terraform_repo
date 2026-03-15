# Terraform v1.9 – Variable Validation Cross-Module & templatestring (June 2024)

## What's New

### 1. Input Variable Validation Using Values from Other Variables

Variables can now reference **other variables** in validation conditions:

```hcl
# Previously: validation could only reference var.<self>
# Now: validation can reference any variable in the same module

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 10

  validation {
    # v1.9+: can reference other variables
    condition     = var.max_capacity >= var.min_capacity
    error_message = "max_capacity (${var.max_capacity}) must be >= min_capacity (${var.min_capacity})"
  }
}

variable "desired_capacity" {
  type = number

  validation {
    condition = (
      var.desired_capacity >= var.min_capacity &&
      var.desired_capacity <= var.max_capacity
    )
    error_message = "desired_capacity must be between min_capacity and max_capacity."
  }
}
```

### 2. `templatestring` Function – Generally Available

Render a template string with variable substitution:

```hcl
locals {
  user_data_template = <<-EOT
    #!/bin/bash
    export APP_ENV="$${environment}"
    export DB_HOST="$${db_host}"
    export LOG_LEVEL="$${log_level}"
    /usr/local/bin/start-app.sh
  EOT

  user_data = templatestring(local.user_data_template, {
    environment = var.environment
    db_host     = module.rds.endpoint
    log_level   = var.environment == "prod" ? "warn" : "debug"
  })
}

resource "aws_launch_template" "app" {
  user_data = base64encode(local.user_data)
}
```

### 3. `issensitive()` in More Contexts

```hcl
# Use issensitive() to conditionally handle sensitive values
locals {
  safe_log_value = issensitive(var.api_key) ? "REDACTED" : var.api_key
}
```

### 4. Enhanced `for` Expression Error Messages

```hcl
variable "instances" {
  type = map(object({
    type = string
    az   = string
  }))

  validation {
    # More descriptive errors for collection validation
    condition = alltrue([
      for k, v in var.instances : contains(["t3.micro", "t3.small", "t3.medium"], v.type)
    ])
    error_message = "All instance types must be t3.micro, t3.small, or t3.medium. Invalid entries: ${join(", ", [for k, v in var.instances : k if !contains(["t3.micro", "t3.small", "t3.medium"], v.type)])}"
  }
}
```

## Upgrade from v1.8

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.9"
}
```

## Summary of Key Version Features (v1.0–v1.9)

| Version | Must-Know Feature |
|---------|------------------|
| v1.0 | Stable API guarantee, `sensitive` variables |
| v1.1 | `moved` block for refactoring, `cloud` block |
| v1.2 | `precondition`/`postcondition`, `replace_triggered_by` |
| v1.3 | `optional()` in object types, `startswith`/`endswith` |
| v1.4 | `import` block (declarative imports) |
| v1.5 | `import` block GA, `check` block, `-generate-config-out` |
| v1.6 | `terraform test` GA, S3 backend improvements |
| v1.7 | `mock_provider` for unit tests, `removed` block |
| v1.8 | Provider-defined functions, Stacks preview |
| v1.9 | Cross-variable validation, `templatestring` GA |
