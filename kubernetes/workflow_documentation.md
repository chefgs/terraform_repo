# GitHub Actions Workflow for Terraform Kubernetes Deployment

This document explains the GitHub Actions workflow used to automate the deployment of Terraform-managed Kubernetes resources. The workflow provides a CI/CD pipeline for testing, planning, applying, and destroying Terraform configurations in a Kubernetes environment.

## Table of Contents

- [Workflow Overview](#workflow-overview)
- [Trigger Events](#trigger-events)
- [Workflow Inputs](#workflow-inputs)
- [Job Structure](#job-structure)
- [Steps Breakdown](#steps-breakdown)
- [Environment Setup](#environment-setup)
- [Terraform Operations](#terraform-operations)
- [Verification](#verification)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Workflow Overview

The workflow automates the process of deploying and managing Kubernetes resources using Terraform. It sets up a Minikube environment for testing, provisions the Terraform-defined resources, and verifies the deployment. This CI/CD pipeline ensures consistent and reliable infrastructure deployments.

## Trigger Events

The workflow is triggered by three different events:

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
      action:
        description: 'Choose Terraform action (plan/apply/destroy)'
        required: false
        default: 'plan'
```

**Explanation:**

- **Push Events**: Automatically runs when code is pushed to the main branch
- **Pull Request Events**: Automatically runs when a pull request is created against the main branch
- **Manual Trigger**: Can be manually triggered via the GitHub Actions UI with customizable parameters:
  - `tfpath`: Path to the Terraform code (defaults to 'kubernetes')
  - `action`: The Terraform action to perform (plan, apply, or destroy)

## Workflow Inputs

When manually triggering the workflow, you can provide the following inputs:

- **TF Code Path**: Specifies the directory containing Terraform code (defaults to 'kubernetes')
- **Terraform action**: Choose between:
  - `plan`: Preview changes without applying (default)
  - `apply`: Apply the Terraform changes
  - `destroy`: Destroy the resources created by Terraform

## Job Structure

The workflow consists of a single job named `terraform` that runs on an Ubuntu runner:

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      TFPATH: ${{ github.event.inputs.tfpath || 'kubernetes' }}
      ACTION: ${{ github.event.inputs.action || 'plan' }}
```

**Environment Variables:**

- `TFPATH`: Sets the path to the Terraform configuration (from input or default)
- `ACTION`: Sets the Terraform action to perform (from input or default)

## Steps Breakdown

### Environment Setup

```yaml
- name: Checkout Code
  uses: actions/checkout@v2.5.0

- name: Setup Minikube
  uses: medyagh/setup-minikube@v0.0.13

- name: Setup kubectl
  uses: Azure/setup-kubectl@v3

- name: Setup Terraform CLI
  uses: hashicorp/setup-terraform@v2.0.2
```

**Explanation:**

1. **Checkout Code**: Retrieves the repository code from GitHub
2. **Setup Minikube**: Creates a local Kubernetes cluster for testing
3. **Setup kubectl**: Installs the Kubernetes command-line tool
4. **Setup Terraform CLI**: Installs the Terraform command-line interface

### Terraform Operations

```yaml
- name: Terraform Init
  run: terraform init
  working-directory: ${{ env.TFPATH }}

- name: Terraform Validate
  run: terraform validate
  working-directory: ${{ env.TFPATH }}

- name: Terraform Plan/Apply/Destroy
  run: |
    if [ "${{ env.ACTION }}" == "plan" ]; then
      terraform plan
    elif [ "${{ env.ACTION }}" == "apply" ]; then
      terraform apply -auto-approve
    elif [ "${{ env.ACTION }}" == "destroy" ]; then
      terraform destroy -auto-approve
    fi
  working-directory: ${{ env.TFPATH }}
```

**Explanation:**

1. **Terraform Init**: Initializes the Terraform configuration and downloads providers
2. **Terraform Validate**: Checks that the configuration is syntactically valid
3. **Terraform Plan/Apply/Destroy**: 
   - Executes the chosen Terraform operation based on the `ACTION` environment variable
   - Uses conditional logic to run the appropriate command
   - Runs with `-auto-approve` to avoid manual confirmation during CI/CD

### Verification

```yaml
- name: Verify Kubernetes Deployment
  if: env.ACTION == 'apply'
  run: kubectl get deployment -n k8s-ns-by-tf
```

**Explanation:**

- Only runs when the action is `apply`
- Verifies that the Kubernetes deployment was created successfully
- Checks for deployments in the namespace created by Terraform (`k8s-ns-by-tf`)

## Best Practices

This workflow implements several CI/CD best practices:

1. **Environment Isolation**: Uses Minikube to create an isolated testing environment
2. **Validation Before Deployment**: Validates Terraform code before applying
3. **Conditional Execution**: Only runs verification steps when applying changes
4. **Parameterized Execution**: Allows customization of path and action
5. **Default Safety**: Uses 'plan' as the default action to prevent accidental changes

## Troubleshooting

If the workflow fails, check the following:

1. **Minikube Setup**: Ensure the Minikube setup step completed successfully
2. **Terraform Validation**: Look for syntax errors in the Terraform code
3. **Kubernetes Resources**: Check if the namespace and resources were created properly
4. **Permission Issues**: Verify that the workflow has the necessary permissions
5. **Resource Constraints**: Check if the runner has enough resources for Minikube

## Usage Examples

### Running a Plan on a PR

When a pull request is made to the main branch, the workflow automatically runs a `plan` operation to show what changes would be made without actually applying them. This helps reviewers understand the impact of the changes.

### Applying Changes in Production

To apply changes to the production environment:

1. Go to the "Actions" tab in your GitHub repository
2. Select "Terraform Kubernetes Workflow New"
3. Click "Run workflow"
4. Set the action to "apply"
5. Click "Run workflow" again

### Cleaning Up Resources

To destroy all resources created by Terraform:

1. Go to the "Actions" tab in your GitHub repository
2. Select "Terraform Kubernetes Workflow New"
3. Click "Run workflow"
4. Set the action to "destroy"
5. Click "Run workflow" again

## Extending the Workflow

This workflow can be extended in several ways:

1. **Multiple Environments**: Add environment-specific configurations (dev, staging, prod)
2. **Approval Gates**: Add manual approval steps before applying to production
3. **Notifications**: Add Slack or email notifications for successful/failed deployments
4. **Drift Detection**: Add scheduled runs to detect configuration drift
5. **State Management**: Configure remote state storage (e.g., S3, Azure Blob Storage)
