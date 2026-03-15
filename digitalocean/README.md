# DigitalOcean – Terraform IaC Examples

Terraform code samples for **DigitalOcean** infrastructure provisioning.

## Directory Structure

```
digitalocean/
├── create-vm/       # Droplet (VM) creation
└── app-platform/    # App Platform deployment from Git repository
```

## Getting Started

```bash
# Set your DigitalOcean API token
export TF_VAR_do_token="dop_v1_..."

cd app-platform/
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```
