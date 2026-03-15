---
layout: default
title: Cloud Providers
nav_order: 4
---

# Multi-Cloud Provider Samples

This section covers Terraform examples for Azure, GCP, DigitalOcean, and Oracle Cloud Infrastructure.

---

## Table of Contents

- [Azure Samples](#azure-samples)
- [GCP Samples](#gcp-samples)
- [DigitalOcean Samples](#digitalocean-samples)
- [Oracle Cloud Samples](#oracle-cloud-samples)
- [Prerequisites by Provider](#prerequisites-by-provider)

---

## Azure Samples

**Path:** `azure/`

Terraform code for provisioning resources on [Microsoft Azure](https://azure.microsoft.com/) using the [AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

### Available Examples

| Directory | Description |
|-----------|-------------|
| `create_vm/` | Azure Virtual Machine provisioning |

### Azure Virtual Machine Example

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"

  admin_username = "adminuser"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
```

### Authentication

Authenticate to Azure using one of:

```bash
# Azure CLI (recommended for development)
az login

# Service Principal (recommended for CI/CD)
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

---

## GCP Samples

**Path:** `gcp/`

Terraform code for [Google Cloud Platform](https://cloud.google.com/) using the [Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

### Available Examples

| Directory | Description |
|-----------|-------------|
| `gcp_resources/` | GCP compute and networking resources |

### GCP Compute Instance Example

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["web", "terraform"]
}
```

### Authentication

```bash
# Using Application Default Credentials
gcloud auth application-default login

# Using a service account key
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
```

---

## DigitalOcean Samples

**Path:** `digitalocean/`

Terraform code for [DigitalOcean](https://www.digitalocean.com/) using the [DigitalOcean provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs).

### Available Examples

| Directory | Description |
|-----------|-------------|
| `create_vm/` | DigitalOcean Droplet (VM) creation |

### Droplet Creation Example

```hcl
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "example" {
  name   = "example-droplet"
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"
  region = "nyc3"

  tags = ["terraform", "example"]
}

output "droplet_ip" {
  value = digitalocean_droplet.example.ipv4_address
}
```

### Authentication

```bash
# Set your DigitalOcean API token
export DIGITALOCEAN_TOKEN="your-api-token"

# Or pass as a variable
terraform apply -var="do_token=your-api-token"
```

---

## Oracle Cloud Samples

**Path:** `oraclecloud/`

Terraform code for [Oracle Cloud Infrastructure (OCI)](https://www.oracle.com/cloud/) using the [OCI provider](https://registry.terraform.io/providers/oracle/oci/latest/docs).

### Key OCI Terraform Concepts

```hcl
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_instance" "example" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "example-instance"
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }

  source_details {
    source_type = "image"
    source_id   = var.os_image_id
  }

  create_vnic_details {
    subnet_id = var.subnet_id
  }
}
```

---

## Prerequisites by Provider

### Azure

| Requirement | How to Set Up |
|-------------|---------------|
| Azure account | [Create free account](https://azure.microsoft.com/free/) |
| Azure CLI | `brew install azure-cli` or [install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| Terraform | [Download Terraform](https://www.terraform.io/downloads) |
| Authentication | `az login` or service principal |

### GCP

| Requirement | How to Set Up |
|-------------|---------------|
| GCP project | [Create project](https://console.cloud.google.com/) |
| gcloud CLI | [Install guide](https://cloud.google.com/sdk/docs/install) |
| Terraform | [Download Terraform](https://www.terraform.io/downloads) |
| Authentication | `gcloud auth application-default login` |

### DigitalOcean

| Requirement | How to Set Up |
|-------------|---------------|
| DigitalOcean account | [Sign up](https://www.digitalocean.com/) |
| API token | [Generate token](https://cloud.digitalocean.com/account/api/tokens) |
| Terraform | [Download Terraform](https://www.terraform.io/downloads) |

### Oracle Cloud

| Requirement | How to Set Up |
|-------------|---------------|
| OCI account | [Create account](https://www.oracle.com/cloud/free/) |
| OCI CLI | [Install guide](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) |
| API keys | [Set up API keys](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm) |
| Terraform | [Download Terraform](https://www.terraform.io/downloads) |

---

## Running Any Cloud Provider Example

```bash
# Clone the repository
git clone https://github.com/chefgs/terraform_repo.git

# Navigate to a cloud provider example
cd terraform_repo/azure/create_vm
# or: cd terraform_repo/gcp/gcp_resources
# or: cd terraform_repo/digitalocean/create_vm
# or: cd terraform_repo/oraclecloud_samples

# Set up cloud credentials (provider-specific, see sections above)

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply
terraform apply

# Destroy when done
terraform destroy
```

---

*[← Back to Kubernetes](./kubernetes)* | *[Next: GitHub Actions →](./github-actions)*
