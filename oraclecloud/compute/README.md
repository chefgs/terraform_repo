# Oracle Cloud Infrastructure – Basic Compute with Networking

Provision a complete basic infrastructure stack on **Oracle Cloud Infrastructure (OCI)** using Terraform, including VCN, subnet, internet gateway, security lists, and a compute instance.

## Architecture

```
OCI Tenancy / Compartment
└── VCN (10.0.0.0/16)
    ├── Internet Gateway
    ├── Route Table (0.0.0.0/0 → IGW)
    ├── Security List (SSH 22, HTTP 80, HTTPS 443)
    └── Public Subnet (10.0.1.0/24)
        └── Compute Instance (Oracle Linux, Flexible Shape)
```

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.5.0 |
| OCI Provider | >= 5.0.0 |
| OCI Account | With IAM permissions for compute/networking |

## OCI API Key Setup

```bash
# 1. Create key pair
oci setup keys

# 2. Upload public key to OCI Console:
#    Identity → Users → Your User → API Keys → Add API Key

# 3. Note down: tenancy_ocid, user_ocid, fingerprint, region
```

## Usage

```bash
# 1. Copy and populate variables
cp terraform.tfvars.example terraform.tfvars

# 2. Initialise
terraform init

# 3. Preview
terraform plan

# 4. Deploy
terraform apply

# 5. SSH into the instance
terraform output ssh_command

# 6. Destroy
terraform destroy
```

## Free Tier

OCI Always Free resources used here:
- `VM.Standard.E4.Flex` with 1 OCPU and 8 GB RAM (Free Tier eligible)
- 50 GB boot volume included

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `tenancy_ocid` | OCI Tenancy OCID | Required |
| `user_ocid` | OCI User OCID | Required |
| `fingerprint` | API Key fingerprint | Required |
| `region` | OCI region | `us-ashburn-1` |
| `compartment_ocid` | Compartment OCID | Required |
| `instance_shape` | Compute shape | `VM.Standard.E4.Flex` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_public_ip` | Public IP of the instance |
| `ssh_command` | Ready-to-use SSH command |
| `vcn_id` | VCN OCID |
