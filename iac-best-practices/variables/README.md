# Variables Best Practices – Terraform

Demonstrates Terraform variable templatization covering:

- Variable types: string, number, bool, list, map, object, tuple
- Input validation with `validation` blocks
- Sensitive variables for secrets
- `locals` for computed/derived values
- Conditional expressions and `for` expressions
- Variable grouping with object types
- `terraform.tfvars` and `.auto.tfvars` patterns
- Environment-specific overrides

## Files

| File | Description |
|------|-------------|
| `main.tf` | Example showing variable usage patterns |
| `variables.tf` | Comprehensive variable definitions |
| `locals.tf` | Local value computations |
| `terraform.tfvars.example` | Example variable file |
| `environments/dev.tfvars` | Dev environment overrides |
| `environments/prod.tfvars` | Prod environment overrides |

## Usage

```bash
# Dev environment
terraform plan -var-file="environments/dev.tfvars"

# Prod environment
terraform plan -var-file="environments/prod.tfvars"

# Override single variable
terraform plan -var="instance_count=3"

# Sensitive variable via environment variable (avoids storing in files)
export TF_VAR_db_password="my-secret-password"
terraform plan
```
