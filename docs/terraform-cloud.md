---
layout: default
title: Terraform Cloud
nav_order: 7
---

# Terraform Cloud Integration

This section covers how to use [Terraform Cloud (TFC)](https://app.terraform.io/) with the examples in this repository, including remote backend configuration, workspace management, and GitHub Actions integration.

---

## Table of Contents

- [What is Terraform Cloud?](#what-is-terraform-cloud)
- [Getting Started with TFC](#getting-started-with-tfc)
- [Remote Backend Configuration](#remote-backend-configuration)
- [Terraform Cloud Workspace Samples](#terraform-cloud-workspace-samples)
- [GitHub Actions Integration](#github-actions-integration)
- [Best Practices and FAQs](#best-practices-and-faqs)

---

## What is Terraform Cloud?

[Terraform Cloud](https://developer.hashicorp.com/terraform/cloud-docs) is HashiCorp's managed service for Terraform that provides:

| Feature | Description |
|---------|-------------|
| **Remote execution** | Run `terraform plan` and `apply` on HashiCorp-managed infrastructure |
| **Remote state storage** | Secure, versioned state file storage with locking |
| **Team collaboration** | Role-based access control and approval workflows |
| **Policy enforcement** | Sentinel policies to enforce governance rules |
| **Variable management** | Store sensitive variables (API keys, passwords) securely |
| **VCS integration** | Trigger runs automatically from GitHub, GitLab, or Bitbucket |
| **Audit logging** | Track all changes for compliance |

### Terraform Cloud vs Local Terraform

| Aspect | Local Terraform | Terraform Cloud |
|--------|----------------|-----------------|
| State storage | Local file or self-managed S3/GCS | Managed, versioned, encrypted |
| Execution | Your machine or CI runner | Remote managed infrastructure |
| Team access | Manual sharing | Role-based permissions |
| Secrets | `.tfvars` or env vars | Encrypted variable storage |
| Cost | Free | Free tier + paid plans |

---

## Getting Started with TFC

**Path:** `tfc-getting-started/`

This directory contains a minimal example for connecting to Terraform Cloud for the first time.

### Prerequisites

1. Create a free [Terraform Cloud account](https://app.terraform.io/signup/account)
2. Create an organization in TFC
3. Generate a [TFC API token](https://app.terraform.io/app/settings/tokens)

### Step 1: Configure the CLI Token

```bash
# Create the Terraform CLI credentials file
cat > ~/.terraform.d/credentials.tfrc.json << EOF
{
  "credentials": {
    "app.terraform.io": {
      "token": "YOUR_TFC_TOKEN_HERE"
    }
  }
}
EOF
```

Or use the CLI:

```bash
terraform login
```

### Step 2: Backend Configuration

```hcl
# backend.tf
terraform {
  cloud {
    organization = "your-organization-name"
    workspaces {
      name = "your-workspace-name"
    }
  }
}
```

### Step 3: Initialize and Run

```bash
cd tfc-getting-started/

# Initialize (connects to TFC and migrates state)
terraform init

# Plan (runs remotely in TFC)
terraform plan

# Apply (runs remotely in TFC)
terraform apply
```

---

## Remote Backend Configuration

The classic way to use Terraform Cloud as a remote backend:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "your-org-name"

    workspaces {
      name = "your-workspace-name"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  # Credentials are stored as workspace environment variables in TFC
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}
```

> **Note:** When using TFC remote execution, store your cloud credentials as **Environment Variables** in the workspace settings, not in your Terraform code.

---

## Terraform Cloud Workspace Samples

**Path:** `tfcloud_samples/`

### Directory Structure

```
tfcloud_samples/
├── amazon_ec2/          # AWS EC2 via TFC remote execution
├── modules/             # Reusable modules for TFC workspaces
├── TFC_Workflow_BestPracticesFAQs.md
└── TFC_Workflow_Explained.md
```

### Amazon EC2 via Terraform Cloud

```hcl
# tfcloud_samples/amazon_ec2/main.tf

terraform {
  cloud {
    organization = "gsaravanan-tf"
    workspaces {
      name = "example-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "tfc_example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name        = "TFC-Managed-Instance"
    ManagedBy   = "TerraformCloud"
  }
}
```

### Setting Up Workspace Variables

In your Terraform Cloud workspace, add:

**Environment Variables (sensitive):**
- `AWS_ACCESS_KEY_ID` = your AWS access key
- `AWS_SECRET_ACCESS_KEY` = your AWS secret key

**Terraform Variables:**
- Any `variable` blocks in your code that need values

---

## GitHub Actions Integration

The `tf_cloud_aws.yml` workflow demonstrates CI/CD integration between GitHub Actions and Terraform Cloud:

### How It Works

```
GitHub Push/PR
     │
     ▼
GitHub Actions Runner
├── Checkout code
├── Setup Terraform with TFC token
├── terraform init (connects to TFC workspace)
└── Create TFC Plan Run
         │
         ▼
    Terraform Cloud
    ├── Download provider plugins
    ├── Download state file
    ├── Run terraform plan
    └── Return plan output
         │
         ▼
GitHub Actions (plan output)
├── Display resource counts (add/change/destroy)
└── (On workflow_dispatch only) terraform apply
```

### Workflow Configuration

```yaml
name: AWS Infra Creation Using TF Cloud

on:
  workflow_dispatch:
  push:
    branches: [ "main" ]

env:
  tfcode_path: tfcloud_samples/amazon_ec2
  tfc_hostname: app.terraform.io
  tfc_organisation: your-org-name
  tfc_workspace: your-workspace-name

jobs:
  aws_tfc_job:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3.5.2

    - name: Setup Terraform with TFC Token
      uses: hashicorp/setup-terraform@v2.0.2
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform init and validate
      run: |
        terraform init
        terraform validate
      working-directory: ${{ env.tfcode_path }}

    - name: Create TFC Plan Run
      uses: hashicorp/tfc-workflows-github/actions/create-run@v1.3.0
      id: run
      with:
        workspace: ${{ env.tfc_workspace }}
        plan_only: true
        hostname: ${{ env.tfc_hostname }}
        token: ${{ secrets.TF_API_TOKEN }}
        organization: ${{ env.tfc_organisation }}

    - name: Get Plan Output
      uses: hashicorp/tfc-workflows-github/actions/plan-output@v1.3.0
      with:
        hostname: ${{ env.tfc_hostname }}
        token: ${{ secrets.TF_API_TOKEN }}
        organization: ${{ env.tfc_organisation }}
        plan: ${{ steps.run.outputs.plan_id }}
```

### Required GitHub Secret

Add `TF_API_TOKEN` to your repository secrets:

1. Go to **Repository Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `TF_API_TOKEN`
4. Value: Your Terraform Cloud API token from [app.terraform.io/app/settings/tokens](https://app.terraform.io/app/settings/tokens)

---

## Best Practices and FAQs

This repository includes detailed documentation files:

- `tfcloud_samples/TFC_Workflow_Explained.md` — Step-by-step TFC workflow explanation
- `tfcloud_samples/TFC_Workflow_BestPracticesFAQs.md` — Common questions and best practices

### Key Best Practices

**1. Use workspace-level variables for secrets**

Never store cloud credentials in Terraform files. Always use TFC workspace environment variables:

```
# In TFC workspace settings → Variables:
AWS_ACCESS_KEY_ID     = "AKIAIOSFODNN7EXAMPLE"  (mark as sensitive)
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/..."      (mark as sensitive)
```

**2. Use workspaces per environment**

```
project-dev       → development environment
project-staging   → staging environment  
project-prod      → production environment
```

**3. Enable state versioning**

TFC automatically versions state files. You can roll back to any previous state if needed.

**4. Use Sentinel policies for governance**

For team environments, define policies that enforce:
- Required tags on all resources
- Allowed instance types
- Restricted regions

**5. VCS-driven workflows**

Connect your TFC workspace to your GitHub repository to automatically trigger plans on every pull request and applies on merge to main.

---

## References

- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [TFC Getting Started Tutorial](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)
- [Terraform Cloud Pricing](https://www.hashicorp.com/products/terraform/pricing)
- [GitHub Actions for Terraform Cloud](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [TFC Sentinel Policies](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement)

---

*[← Back to Custom Providers](./custom-provider.md)* | *[Back to Home →](./)*
