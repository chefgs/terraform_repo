# Lock File Management – Terraform Best Practices

The `.terraform.lock.hcl` file pins provider versions and their checksums for reproducible deployments.

## Why Commit the Lock File?

```
Without lock file → team members get different provider versions → inconsistent behaviour
With lock file    → everyone uses exact same provider version    → reproducible builds
```

## Lock File Contents

```hcl
# .terraform.lock.hcl example
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.31.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:abc123...",                  # ziphash
    "zh:def456...",                  # package hash
  ]
}
```

## Common Commands

### Initial lock file generation

```bash
terraform init
# Creates .terraform.lock.hcl with hashes for current platform
```

### Add hashes for multiple platforms (CI/CD + local dev)

```bash
# Lock for Linux (CI/CD), macOS Intel, macOS ARM, Windows
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64 \
  -platform=windows_amd64
```

### Upgrade a specific provider

```bash
terraform init -upgrade
# Updates providers to latest versions within constraints
# Updates .terraform.lock.hcl automatically
```

### Verify lock file integrity

```bash
terraform providers lock -platform=linux_amd64
# Re-fetches and verifies checksums
```

## .gitignore Rules

```gitignore
# IGNORE .terraform directory (cache, downloaded plugins)
.terraform/

# INCLUDE lock file (version pinning)
!.terraform.lock.hcl

# IGNORE state files (sensitive data)
*.tfstate
*.tfstate.backup

# IGNORE variable files with secrets
*.auto.tfvars
terraform.tfvars
```

## Platform-Specific Hashes

When your team uses different OS/architectures, run:

```bash
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_arm64
```

This ensures the lock file works for:
- CI/CD pipelines (linux_amd64)
- macOS M1/M2 developers (darwin_arm64)
- macOS Intel developers (darwin_amd64)

## Lock File in CI/CD

```yaml
# GitHub Actions example
- name: Terraform Init
  run: terraform init
  # Lock file ensures CI uses same provider versions as dev

- name: Verify lock file not modified
  run: |
    if ! git diff --exit-code .terraform.lock.hcl; then
      echo "ERROR: Lock file was modified. Run 'terraform init' locally and commit."
      exit 1
    fi
```

## Troubleshooting

| Problem | Solution |
|---------|---------|
| `Error: Failed to install provider` | Run `terraform init -upgrade` |
| Lock file has wrong platform hashes | Run `terraform providers lock -platform=...` |
| Provider version conflict | Update version constraints in `required_providers` |
| CI gets different version than local | Commit the `.terraform.lock.hcl` file |
