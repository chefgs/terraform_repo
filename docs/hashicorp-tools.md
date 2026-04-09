---
layout: default
title: HashiCorp Tools
nav_order: 6
---

# HashiCorp Tools – 2-Tier AWS App

Deploy a production-grade 2-tier application on AWS using the **full HashiCorp stack**: Packer, Vault, Consul, and Boundary.

---

## Architecture

```
AWS Region
├── VPC
│   ├── Public Subnets    → Web Tier (Nginx, Consul agent)
│   └── Private Subnets   → App Tier (Node.js, Consul agent, Vault agent)
│
├── Packer    → Builds hardened AMIs with agents pre-installed
├── Vault     → Manages dynamic secrets, PKI, IAM auth
├── Consul    → Service discovery and health checks
└── Boundary  → Zero-trust SSH access for developers and ops
```

---

## Tools Overview

### 🔨 Packer – AMI Builder

**Path:** `hashicorp-tools/packer/`

Builds two hardened AMIs:

| AMI | Pre-installed | Use |
|-----|--------------|-----|
| `2tier-web-server` | Nginx, Consul agent | Web tier (public subnet) |
| `2tier-app-server` | Node.js, Consul agent, Vault agent | App tier (private subnet) |

**Build:**
```bash
cd hashicorp-tools/packer/
packer init ami.pkr.hcl
packer build ami.pkr.hcl
```

---

### 🔐 Vault – Secrets Management

**Path:** `hashicorp-tools/vault/`

Configures Vault with:

- **KV v2** – Application configuration secrets
- **Database** – Dynamic PostgreSQL credentials (auto-rotated, TTL: 1h)
- **PKI** – Internal TLS certificate authority
- **AWS IAM Auth** – Passwordless authentication for EC2 instances

**Dynamic Credentials Flow:**
```
EC2 Instance → sts:GetCallerIdentity → Vault Token → DB Creds (1h TTL) → Auto-revoked
```

---

### 🔗 Consul – Service Discovery

**Path:** `hashicorp-tools/consul/`

Provisions a 3-node Consul server cluster with:

- EC2 auto-join via AWS instance tags (no hardcoded IPs)
- Consul Connect service mesh enabled
- DNS-based service resolution: `app-server.service.consul`
- IMDSv2 enforced on all instances

---

### 🔒 Boundary – Zero-Trust Access

**Path:** `hashicorp-tools/boundary/`

Controls SSH access to private EC2 instances with:

| Group | Web Tier | App Tier |
|-------|----------|----------|
| `developers` | ❌ | ✅ SSH |
| `operations` | ✅ SSH | ✅ SSH |

**Connect:**
```bash
boundary connect ssh \
  -target-id=$(terraform output -raw app_ssh_target_id) \
  -username ec2-user
```

---

## Deployment Order

1. **Packer** – Build AMIs
2. **Vault** – Bootstrap secrets management
3. **Consul** – Enable service discovery
4. **Boundary** – Configure access control

---

## Related

- [AWS Samples](./aws-samples.md)
- [IaC Best Practices](./iac-best-practices.md)
