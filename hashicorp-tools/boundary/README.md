# Boundary – Zero-Trust Access Control for 2-Tier AWS App

Configure **HashiCorp Boundary** for zero-trust, identity-based access to private AWS EC2 instances in the 2-tier application, with Vault-backed SSH certificate injection.

## Architecture

```
Developer / Ops Engineer
    │
    ▼
Boundary Controller (HCP / Self-hosted)
    │
    ├── Dynamic Host Catalog (AWS Plugin – discovers EC2 by tags)
    │   ├── Host Set: web-tier  (tag:Tier=web)
    │   └── Host Set: app-tier  (tag:Tier=app)
    │
    ├── Vault Credential Store
    │   ├── SSH certs for web-tier
    │   └── SSH certs for app-tier
    │
    └── Targets
        ├── web-tier-ssh  → ops group only
        └── app-tier-ssh  → dev group (read-only) + ops group
```

## Access Model

| Group | Web Tier | App Tier |
|-------|----------|----------|
| `developers` | ❌ No access | ✅ SSH (read-only) |
| `operations` | ✅ SSH | ✅ SSH |

## Connect to an Instance

```bash
# Authenticate
boundary authenticate password \
  -auth-method-id=<auth_method_id> \
  -login-name=ops-user

# Connect to app-tier instance
boundary connect ssh \
  -target-id=$(terraform output -raw app_ssh_target_id) \
  -username ec2-user
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```
