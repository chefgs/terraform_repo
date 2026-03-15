# Oracle Cloud Infrastructure – Terraform IaC Examples

Terraform code samples for **Oracle Cloud Infrastructure (OCI)** provisioning.

## Directory Structure

```
oraclecloud/
├── create-vcn/    # Virtual Cloud Network creation
└── compute/       # Compute instance with full networking stack
```

## Getting Started

```bash
# Setup OCI CLI and API key
oci setup config

cd compute/
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```
