---
layout: default
title: GitHub Actions
nav_order: 5
---

# GitHub Actions Workflows

This repository uses [GitHub Actions](https://docs.github.com/en/actions) to automate Terraform validation, deployment, and infrastructure lifecycle management across multiple cloud providers.

---

## Table of Contents

- [Overview](#overview)
- [Terraform AWS Workflow](#terraform-aws-workflow)
- [Terraform Kubernetes Workflow](#terraform-kubernetes-workflow)
- [Terraform Cloud AWS Workflow](#terraform-cloud-aws-workflow)
- [GitHub Pages Workflow](#github-pages-workflow)
- [How to Trigger Workflows Manually](#how-to-trigger-workflows-manually)
- [Workflow Security](#workflow-security)

---

## Overview

| Workflow File | Name | Triggers | Purpose |
|--------------|------|----------|---------|
| `tf_code_validation_aws.yml` | Terraform AWS Workflow | Push, PR, Manual | Validates and applies AWS Terraform code |
| `tf_code_validation_k8s.yml` | Terraform Kubernetes Workflow | Push, PR, Manual | Deploys Kubernetes resources via Terraform |
| `tf_cloud_aws.yml` | AWS Infra via TF Cloud | Push, PR, Manual | Runs Terraform plans via Terraform Cloud |
| `pages.yml` | Deploy GitHub Pages | Push to main, Manual | Builds and deploys this documentation site |

All workflows are stored in `.github/workflows/`.

---

## Terraform AWS Workflow

**File:** `.github/workflows/tf_code_validation_aws.yml`

This workflow validates and applies AWS Terraform configurations.

### Triggers

```yaml
on:
  workflow_call:        # Can be called by other workflows
  workflow_dispatch:    # Manual trigger with inputs
    inputs:
      tfpath:
        description: 'TF File Path'
        required: false
        default: 'aws_samples/create_ec2'
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
```

### Job Steps

```
1. Checkout code
2. Configure AWS credentials (from GitHub Secrets)
3. Setup Terraform CLI
4. terraform init + terraform validate
5. terraform plan + terraform apply
6. terraform destroy (cleanup)
```

### Required Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY` | AWS Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key |

### Full Workflow

```yaml
name: Terraform AWS Workflow

on:
  workflow_call:
  workflow_dispatch:
    inputs:
      tfpath:
        description: 'TF File Path'
        required: false
        default: 'aws_samples/create_ec2'
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  tf_code_check:
    name: Terraform Validation and Build
    runs-on: ubuntu-latest
    if: ${{ inputs.tfpath }}
    steps:
    - name: Checkout tf code in runner environment
      uses: actions/checkout@v3.5.2

    - name: Configure AWS Credentials Action For GitHub Actions
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2

    - name: Setup Terraform CLI
      uses: hashicorp/setup-terraform@v2.0.2

    - name: Terraform init and validate
      run: |
        terraform init
        terraform validate
      working-directory: ${{ github.event.inputs.tfpath }}

    - name: Terraform plan and apply
      run: |
        terraform plan
        terraform apply -auto-approve
      working-directory: ${{ github.event.inputs.tfpath }}

    - name: Terraform Destroy
      run: terraform destroy -auto-approve
      working-directory: ${{ github.event.inputs.tfpath }}
```

---

## Terraform Kubernetes Workflow

**File:** `.github/workflows/tf_code_validation_k8s.yml`

This workflow deploys Kubernetes resources to a Minikube cluster running inside the GitHub Actions runner.

### Triggers

```yaml
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:
    inputs:
      tfpath:
        description: 'TF Code Path'
        required: false
        default: 'kubernetes'
```

### Job Steps

```
1. Checkout code
2. Start Minikube cluster (medyagh/setup-minikube)
3. Install kubectl (Azure/setup-kubectl)
4. Setup Terraform CLI
5. terraform init + terraform validate + terraform plan
6. terraform apply
7. kubectl get deployment (verification)
8. terraform plan -destroy (cleanup plan)
```

### Unique Features

- **Minikube integration** — Spins up a full K8s cluster in the CI runner
- **kubectl verification** — Confirms the deployment was created successfully
- **No external cluster needed** — Self-contained test environment

### Full Workflow

```yaml
name: Terraform Kubernetes Workflow

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:
    inputs:
      tfpath:
        description: 'TF Code Path'
        required: false
        default: 'kubernetes'

jobs:
  tf_code_check:
    name: Terraform Validation and Build
    runs-on: ubuntu-latest
    if: ${{ inputs.tfpath }}
    steps:
    - name: Checkout Code
      uses: actions/checkout@v2.5.0

    - name: Install Minikube for GitHub Actions
      uses: medyagh/setup-minikube@v0.0.13

    - name: Install Kubectl tool for GitHub Actions
      uses: Azure/setup-kubectl@v3

    - name: Setup Terraform CLI
      uses: hashicorp/setup-terraform@v2.0.2

    - name: Terraform init and validate and plan
      run: |
        terraform init
        terraform validate
        terraform plan
      working-directory: ${{ github.event.inputs.tfpath }}

    - name: Terraform Apply
      run: terraform apply -auto-approve
      working-directory: ${{ github.event.inputs.tfpath }}

    - name: Verify Kubernetes Deployment
      run: kubectl get deployment -n k8s-ns-by-tf

    - name: Terraform Destroy
      run: terraform plan -destroy
      working-directory: ${{ github.event.inputs.tfpath }}
```

---

## Terraform Cloud AWS Workflow

**File:** `.github/workflows/tf_cloud_aws.yml`

This workflow integrates GitHub Actions with [Terraform Cloud](https://app.terraform.io/) for managed remote plan and apply operations.

### Triggers

```yaml
on:
  workflow_call:
    secrets:
      TF_API_TOKEN:
        required: true
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:
```

### Environment Variables

```yaml
env:
  tfcode_path: tfcloud_samples/amazon_ec2
  tfc_hostname: app.terraform.io
  tfc_organisation: gsaravanan-tf
  tfc_workspace: example-workspace
```

### Job Structure

This workflow has two jobs:

**Job 1: `aws_tfc_job`** (runs on push/PR/dispatch)
1. Checkout code
2. Configure Terraform Cloud CLI with API token
3. `terraform init` and `terraform validate`
4. Create a plan-only run via Terraform Cloud API
5. Output plan summary (add/change/destroy counts)

**Job 2: `apply_terraform_plan`** (runs only on `workflow_dispatch`)
1. Depends on job 1 completing
2. `terraform init`, `terraform validate`
3. `terraform apply -auto-approve`
4. `terraform destroy -auto-approve`

### Required Secrets

| Secret | Description |
|--------|-------------|
| `TF_API_TOKEN` | Terraform Cloud API token |

### Key Actions Used

| Action | Purpose |
|--------|---------|
| `hashicorp/setup-terraform@v2.0.2` | Install and configure Terraform CLI with TFC credentials |
| `hashicorp/tfc-workflows-github/actions/create-run@v1.3.0` | Trigger a Terraform Cloud plan run |
| `hashicorp/tfc-workflows-github/actions/plan-output@v1.3.0` | Fetch and display plan output |

---

## GitHub Pages Workflow

**File:** `.github/workflows/pages.yml`

This workflow builds and deploys the documentation site (what you're reading now) to [GitHub Pages](https://pages.github.com/).

### Triggers

```yaml
on:
  push:
    branches: ["main"]
  workflow_dispatch:
```

### Permissions

```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

### Job Structure

**Job 1: `build`**
1. Checkout repository
2. Configure GitHub Pages settings
3. Build Jekyll site from `docs/` directory
4. Upload the built site as a GitHub Actions artifact

**Job 2: `deploy`**
1. Depends on `build` job
2. Deploys the uploaded artifact to the `github-pages` environment
3. Returns the published page URL

---

## How to Trigger Workflows Manually

1. Go to the [Actions tab](https://github.com/chefgs/terraform_repo/actions) in the repository
2. Select the workflow you want to run from the left sidebar
3. Click the **"Run workflow"** dropdown button
4. Fill in any required inputs (e.g., `tfpath` for AWS or Kubernetes workflows)
5. Click **"Run workflow"** to start the job
6. Monitor the job progress in real-time from the workflow run page

---

## Workflow Security

### Secrets Management

All sensitive values are stored as [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets), never hardcoded in workflow files:

- Cloud credentials (`AWS_ACCESS_KEY`, `AWS_SECRET_ACCESS_KEY`)
- API tokens (`TF_API_TOKEN`)

### Principle of Least Privilege

- The GitHub Pages workflow only requests `pages: write` and `id-token: write` permissions
- AWS credentials are scoped per workflow run
- Terraform Cloud tokens are organization-scoped

### Concurrency Control

The GitHub Pages workflow uses concurrency groups to prevent simultaneous deployments:

```yaml
concurrency:
  group: "pages"
  cancel-in-progress: false
```

---

## Adding a New Workflow

To add a new Terraform workflow for a different cloud provider:

1. Create a new file in `.github/workflows/` (e.g., `tf_code_validation_azure.yml`)
2. Use the AWS workflow as a template
3. Replace the AWS credential step with the appropriate cloud provider authentication
4. Update the `tfpath` default to your example directory
5. Add required secrets to the repository settings

---

*[← Back to Cloud Providers](./cloud-providers.md)* | *[Next: Custom Providers →](./custom-provider.md)*
