# Terraform v1.4 – import Block (March 2023)

## What's New

### 1. `import` Block – Declarative Import (Experimental → Stable in v1.5)

Define imports **in your configuration** instead of using CLI commands. This allows importing to be part of your normal plan/apply workflow:

```hcl
# Import an existing VPC into Terraform state
import {
  id = "vpc-12345678"
  to = aws_vpc.main
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Import into a module
import {
  id = "subnet-12345678"
  to = module.networking.aws_subnet.public[0]
}

# Import into for_each resources
import {
  for_each = {
    us-east-1 = "subnet-aaaa1111"
    us-west-2 = "subnet-bbbb2222"
  }
  id = each.value
  to = aws_subnet.regional[each.key]
}
```

**Workflow:**
```bash
# 1. Add import block to config
# 2. Run plan to preview
terraform plan
# 3. Apply to import
terraform apply
# 4. Remove import block (resource is now managed)
```

### 2. Improved Error Messages

v1.4 significantly improved error messages with:
- Clearer variable validation errors
- Better module source error messages
- More actionable suggestions

### 3. `TF_CLI_ARGS_*` Environment Variables

```bash
# Set default args for specific commands
export TF_CLI_ARGS_plan="-out=tfplan"
export TF_CLI_ARGS_apply="-parallelism=20"

# Now 'terraform plan' automatically includes -out=tfplan
terraform plan
```

### 4. S3 Backend Improvements

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"

    # v1.4: Native assume_role_with_web_identity support
    assume_role_with_web_identity {
      role_arn                = "arn:aws:iam::123456789012:role/TerraformRole"
      web_identity_token_file = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
    }
  }
}
```

## Upgrade from v1.3

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.4"
}
```
