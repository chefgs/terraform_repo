# Vault – Secrets Management for 2-Tier AWS App

Configure **HashiCorp Vault** to manage secrets for the 2-tier application using Terraform, including AWS IAM authentication, dynamic database credentials, and PKI certificate issuance.

## Features

| Engine | Purpose |
|--------|---------|
| **KV v2** | Application configuration secrets |
| **Database** | Dynamic PostgreSQL credentials (auto-rotated) |
| **PKI** | Internal TLS certificate authority |
| **AWS Auth** | Passwordless IAM-based authentication for EC2 |

## Prerequisites

- Vault cluster running and unsealed
- AWS RDS PostgreSQL instance accessible from Vault
- Vault admin token for bootstrapping

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Dynamic Credentials Flow

```
EC2 Instance (app-tier)
  1. Calls sts:GetCallerIdentity (IAM auth)
  2. Vault verifies AWS identity → issues Vault token
  3. App requests DB creds: vault read database/creds/app-server-role
  4. Vault creates temporary PostgreSQL user (TTL: 1h)
  5. App connects to DB with ephemeral credentials
  6. Credentials auto-revoked after TTL
```
