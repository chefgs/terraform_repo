---
layout: default
title: Azure Samples
nav_order: 3
---

# Azure Terraform Samples

This section covers Azure infrastructure provisioning examples using Terraform's [AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

---

## Table of Contents

- [Overview](#overview)
- [Virtual Machine](#virtual-machine)
- [Authentication](#authentication)
- [CI Validation](#ci-validation)
- [Running the Code](#running-the-code)

---

## Overview

The `azure/` directory contains Terraform examples for provisioning resources on [Microsoft Azure](https://azure.microsoft.com/).

```
azure/
└── create-vm/     # Azure Virtual Machine with VNet and Resource Group
```

---

## Virtual Machine

**Path:** `azure/create-vm/`

This example provisions a basic Azure infrastructure stack:

- **Resource Group** — Logical container for all related Azure resources
- **Virtual Network (VNet)** — Private network (`10.0.0.0/16`) for the VM
- **AzureRM Provider** — Version-pinned to `=3.0.0` for reproducibility

### Example Code

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}
```

### Terraform Concepts Illustrated

| Concept | Example |
|---------|---------|
| Required providers block | `source = "hashicorp/azurerm"`, `version = "=3.0.0"` |
| Provider features block | `provider "azurerm" { features {} }` |
| Resource group | `azurerm_resource_group` |
| Resource references | `azurerm_resource_group.example.location` |

---

## Authentication

Terraform supports several methods for authenticating to Azure:

```bash
# Option 1: Azure CLI (recommended for local development)
az login
az account set --subscription "<subscription-id>"

# Option 2: Service Principal with client secret (recommended for CI/CD)
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"

# Option 3: Managed Identity (recommended for Azure-hosted runners)
# No credentials needed — Azure assigns the identity automatically
```

Full authentication guide: [Authenticating to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)

### Prerequisites

| Requirement | How to Set Up |
|-------------|---------------|
| Azure account | [Create free account](https://azure.microsoft.com/free/) |
| Azure CLI | `brew install azure-cli` or [install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| Terraform | [Download Terraform](https://www.terraform.io/downloads) |

---

## CI Validation

The repository includes a **[Terraform Azure Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_azure.yml)** GitHub Actions workflow that automatically runs on every push and pull request touching the `azure/` directory.

The workflow runs:
```bash
terraform init -backend=false
terraform validate
```

This confirms all Azure Terraform code is syntactically valid without requiring Azure credentials.

[![Terraform Azure Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_azure.yml/badge.svg)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_azure.yml)

---

## Running the Code

```bash
# 1. Clone the repository
git clone https://github.com/chefgs/terraform_repo.git
cd terraform_repo/azure/create-vm

# 2. Log in to Azure
az login

# 3. Initialize Terraform (downloads the AzureRM provider)
terraform init

# 4. Preview changes
terraform plan

# 5. Apply the configuration
terraform apply

# 6. Clean up when done
terraform destroy
```

---

*[← Back to AWS Samples](./aws-samples.md)* | *[Next: GCP Samples →](./gcp-samples.md)*
