# IaC Best Practices – Terraform

A reference collection of Terraform best practices covering modular architecture, variable templatization, automated testing, and lock file management.

## Contents

| Directory | Topic |
|-----------|-------|
| [`modules/`](./modules/) | Modular resource creation – reusable, composable modules |
| [`variables/`](./variables/) | Variable templatization – types, validation, locals |
| [`testing/`](./testing/) | Terraform native tests (`.tftest.hcl`) |
| [`lock-file-management/`](./lock-file-management/) | Lock file strategy and management |

## Quick Reference

### Modular Design Principles
- One module per logical concern (VPC, EC2, RDS, etc.)
- Modules accept inputs via `variables.tf`, produce outputs via `outputs.tf`
- Use semantic versioning on published modules
- Root module orchestrates child modules

### Variable Best Practices
- Use `sensitive = true` for secrets
- Add `validation` blocks for input constraints
- Use `locals` for derived/computed values
- Group related variables with consistent naming

### Testing
- Write tests using `terraform test` (v1.6+)
- Test happy path and edge cases
- Use `mock_provider` (v1.7+) to avoid real infrastructure

### Lock Files
- Always commit `.terraform.lock.hcl` to version control
- Update with `terraform providers lock` for all platforms
- Never manually edit the lock file
