# Terraform v1.1 – moved block & cloud backend (December 2021)

## What's New

### 1. `moved` Block – Refactor Without Destroying Resources

The `moved` block allows you to **rename or move resources** in Terraform state without destroying and recreating them.

```hcl
# Renamed resource: aws_instance.web → aws_instance.web_server
moved {
  from = aws_instance.web
  to   = aws_instance.web_server
}

# Moved resource into a module
moved {
  from = aws_security_group.web_sg
  to   = module.web.aws_security_group.this
}

# Moved module (renamed module)
moved {
  from = module.old_name
  to   = module.new_name
}
```

**Key Points:**
- Add `moved` blocks during refactoring
- After the move is applied, the `moved` block can be removed
- Keep moved blocks if publishing modules to alert users

### 2. `cloud` Block – Native Terraform Cloud Backend

Replace the `backend "remote"` block with the cleaner `cloud` block:

```hcl
# Old way (still works)
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-org"
    workspaces {
      name = "my-workspace"
    }
  }
}

# New way (v1.1+) – cloud block
terraform {
  cloud {
    hostname     = "app.terraform.io"  # default, can omit
    organization = "my-org"

    workspaces {
      name = "my-workspace"
      # or use tags for multiple workspaces:
      # tags = ["aws", "production"]
    }
  }
}
```

### 3. Provider `required_providers` Meta-arguments

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # New in 1.1: configuration_aliases for aliased providers
      configuration_aliases = [aws.alternate]
    }
  }
}
```

## Upgrade from v1.0

No breaking changes. Simply update `required_version`:

```hcl
terraform {
  required_version = ">= 1.1"
}
```
