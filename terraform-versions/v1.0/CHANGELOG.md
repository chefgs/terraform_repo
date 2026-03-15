# Terraform v1.0 – Stable Release (June 2021)

## What's New

Terraform 1.0 marked the **first stable, production-ready release** with an explicit backward compatibility guarantee for the configuration language and state file format.

### Key Guarantees
- No breaking changes to `.tf` configuration syntax within the 1.x series
- State file format backward compatible
- Provider protocol compatibility

### Notable Refinements from 0.x
- Improved error messages with source location context
- `sensitive` variable support (introduced in 0.14, fully stable in 1.0)
- `depends_on` on modules
- Terraform state show improvements

## Code Examples

### Sensitive Variables
```hcl
# Sensitive variable – value redacted in plan/apply output
variable "db_password" {
  type      = string
  sensitive = true
}
```

### Module depends_on
```hcl
# Ensure network is created before compute module
module "compute" {
  source     = "./modules/compute"
  depends_on = [module.network]
}
```

### Required Provider Versioning (Best Practice)
```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Upgrade from 0.15

```bash
# 1. Update required_version
terraform {
  required_version = ">= 1.0"
}

# 2. Run init to update lock file
terraform init -upgrade

# 3. Plan to verify no unexpected changes
terraform plan
```
