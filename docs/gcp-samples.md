---
layout: default
title: GCP Samples
nav_order: 4
---

# GCP Terraform Samples

This section covers Google Cloud Platform infrastructure provisioning examples using Terraform's [Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

---

## Table of Contents

- [Overview](#overview)
- [Compute Instance](#compute-instance)
- [Authentication](#authentication)
- [CI Validation](#ci-validation)
- [Running the Code](#running-the-code)

---

## Overview

The `gcp/` directory contains Terraform examples for provisioning resources on [Google Cloud Platform](https://cloud.google.com/).

```
gcp/
└── resources/     # GCP Compute instance with static IP and startup script
    ├── gcp-vm.tf        # Main resource definitions
    ├── variables.tf     # Input variables (project, region, zone, VM settings)
    └── initscript.sh    # VM startup script
```

---

## Compute Instance

**Path:** `gcp/resources/`

This example provisions a GCP Compute Engine VM with a static external IP address.

### Key Features

- **Static IP address** — Reserved via `google_compute_address` for a stable external endpoint
- **Compute instance** — Configurable machine type, image, and disk type
- **Startup script** — Runs `initscript.sh` at first boot via `metadata_startup_script`
- **Service account** — Uses `cloud-platform` scope with IAM-controlled permissions
- **Network tags** — Tags the VM for use in firewall rules (`http-server`, `https-server`)

### Example Code

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  credentials = var.creds_file
  project     = var.gcp_project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.vm_type

  tags = ["vm", "tf", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image      # e.g. "centos-cloud/centos-7"
      type  = var.vm_image_type # e.g. "pd-standard"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = file(var.metadata_script)

  service_account {
    email  = var.source_account_email
    scopes = ["cloud-platform"]
  }
}
```

### Input Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `gcp_project_id` | (required) | GCP project ID |
| `region` | `us-central1` | GCP region |
| `zone` | `us-central1-c` | GCP zone |
| `vm_name` | `gcp_tf_vm` | Name for the compute instance |
| `vm_type` | `n1-standard-1` | Machine type |
| `vm_image` | `centos-cloud/centos-7` | Boot disk image |
| `vm_image_type` | `pd-standard` | Disk type |
| `creds_file` | `.keys/account.json` | Path to service account key JSON |
| `metadata_script` | `initscript_chef.sh` | Path to startup script |

---

## Authentication

```bash
# Option 1: Application Default Credentials (recommended for local dev)
gcloud auth application-default login

# Option 2: Service account key file (recommended for CI/CD)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
# or set via variable:
# terraform apply -var="creds_file=/path/to/key.json"

# Option 3: Workload Identity Federation (recommended for GitHub Actions)
# No static credentials — uses short-lived tokens from GitHub OIDC
```

### Prerequisites

| Requirement | How to Set Up |
|-------------|---------------|
| GCP project | [Create project](https://console.cloud.google.com/) |
| gcloud CLI | [Install guide](https://cloud.google.com/sdk/docs/install) |
| Service account | [Create SA + download JSON key](https://console.cloud.google.com/iam-admin/serviceaccounts) |
| Terraform | [Download Terraform](https://www.terraform.io/downloads) |

---

## CI Validation

The repository includes a **[Terraform GCP Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_gcp.yml)** GitHub Actions workflow that automatically runs on every push and pull request touching the `gcp/` directory.

The workflow runs:
```bash
terraform init -backend=false
terraform validate
```

This confirms all GCP Terraform code is syntactically valid without requiring GCP credentials.

[![Terraform GCP Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_gcp.yml/badge.svg)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_gcp.yml)

---

## Running the Code

```bash
# 1. Clone the repository
git clone https://github.com/chefgs/terraform_repo.git
cd terraform_repo/gcp/resources

# 2. Place your service account key
mkdir -p .keys
cp /path/to/your/key.json .keys/account.json

# 3. Initialize Terraform (downloads the Google provider)
terraform init

# 4. Preview changes
terraform plan -var="gcp_project_id=<your-project-id>"

# 5. Apply the configuration
terraform apply -var="gcp_project_id=<your-project-id>"

# 6. Clean up when done
terraform destroy -var="gcp_project_id=<your-project-id>"
```

---

*[← Back to Azure Samples](./azure-samples.html)* | *[Next: Cloud Providers →](./cloud-providers.html)*
