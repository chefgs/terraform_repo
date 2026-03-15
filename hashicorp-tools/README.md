# HashiCorp Tools – 2-Tier AWS Application Deployment

This directory contains Terraform and HashiCorp toolchain examples for deploying a production-grade **2-tier application on AWS** using the full HashiCorp stack.

## Architecture Overview

```
AWS Region (us-east-1)
├── VPC
│   ├── Public Subnet (Web Tier)
│   │   └── ALB → Web Server ASG (AMI built by Packer)
│   └── Private Subnet (App Tier)
│       └── App Server ASG (AMI built by Packer)
│           └── RDS PostgreSQL
│
└── HashiCorp Services
    ├── Packer    – Bakes golden AMIs for web & app tiers
    ├── Vault     – Dynamic secrets, PKI, DB credentials
    ├── Consul    – Service discovery, health checks, KV store
    └── Boundary  – Zero-trust access to private resources
```

## Directory Structure

```
hashicorp-tools/
├── packer/      # Packer templates for AMI creation
├── vault/       # Vault cluster + policies for secrets management
├── consul/      # Consul cluster + service discovery
└── boundary/    # Boundary controller + workers + targets
```

## Getting Started

Deploy in this order:
1. **Packer** – Build the base AMIs
2. **Vault** – Bootstrap secrets management
3. **Consul** – Enable service discovery
4. **Boundary** – Configure zero-trust access

See each sub-directory for detailed instructions.
