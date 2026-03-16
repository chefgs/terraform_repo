# Terraform – 2-Tier AWS Infrastructure

This directory contains the core Terraform code that provisions the **AWS infrastructure** for the 2-tier application. The HashiCorp toolchain sub-directories (`packer/`, `vault/`, `consul/`, `boundary/`) build on top of this foundation.

## Architecture

```
Internet
    │
    ▼
 [ ALB ]  ←── public subnets (us-east-1a, us-east-1b)
    │
    ▼
[ Web ASG ]  ←── AMI baked by Packer  (Nginx reverse-proxy)
    │
    ▼  (internal ALB)
[ App ASG ]  ←── AMI baked by Packer  (Node.js API, Vault agent, Consul agent)
    │
    ▼
[ RDS PostgreSQL ]  ←── private subnets, Multi-AZ
```

## Resources Created

| Resource | Description |
|---|---|
| `aws_vpc` | VPC with DNS support |
| `aws_subnet` (×4) | 2 public + 2 private subnets across 2 AZs |
| `aws_internet_gateway` | Internet access for public subnets |
| `aws_nat_gateway` (×2) | Outbound internet access for private subnets (HA) |
| `aws_lb` (×2) | Public-facing ALB (web) + internal ALB (app) |
| `aws_launch_template` (×2) | Launch templates for web and app tier ASGs |
| `aws_autoscaling_group` (×2) | Web tier ASG (public) + app tier ASG (private) |
| `aws_db_instance` | RDS PostgreSQL (Multi-AZ) in private subnets |
| `aws_security_group` (×5) | ALB, internal ALB, web tier, app tier, RDS |
| `aws_iam_role` (×2) | EC2 instance roles for Vault IAM auth & Consul auto-join |

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | >= 1.3.0 |
| AWS Provider | ~> 5.0 |
| AWS CLI | >= 2.0 |

## Required Variables

| Variable | Description |
|---|---|
| `web_ami_id` | AMI ID built by `../packer` for the web tier |
| `app_ami_id` | AMI ID built by `../packer` for the app tier |
| `db_password` | Master password for RDS PostgreSQL |

## Usage

```bash
# 1. First build AMIs with Packer (see ../packer/README.md)
cd ../packer
packer build ami.pkr.hcl

# 2. Initialize Terraform
cd ../terraform
terraform init

# 3. Review the plan
terraform plan \
  -var="web_ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="app_ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="db_password=<secret>"

# 4. Apply
terraform apply \
  -var="web_ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="app_ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="db_password=<secret>"

# 5. Destroy when done
terraform destroy \
  -var="web_ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="app_ami_id=ami-xxxxxxxxxxxxxxxxx" \
  -var="db_password=<secret>"
```

## Outputs

After a successful `terraform apply`, the following values are available for use by the HashiCorp toolchain modules:

| Output | Used By |
|---|---|
| `vpc_id` | `../consul`, `../boundary` |
| `private_subnet_ids` | `../consul`, `../boundary` |
| `rds_endpoint` | `../vault` (dynamic DB credentials) |
| `alb_dns_name` | Application access URL |

## Next Steps

After provisioning the infrastructure, configure the HashiCorp toolchain in this order:

1. **`../vault`** – Secrets management (dynamic DB credentials, PKI, KV store)
2. **`../consul`** – Service discovery and health checks
3. **`../boundary`** – Zero-trust access to private resources
