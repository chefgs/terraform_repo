# IaC Best Practices – Modular Resource Creation

This example demonstrates the standard Terraform module pattern with:
- A reusable VPC module
- A reusable EC2 module
- A reusable Security Group module
- A root module that wires them together

## Module Structure

```
modules/
├── vpc/              # VPC + subnets + IGW + route tables
├── ec2/              # EC2 instances + ASG + launch template
├── security-group/   # Security group rules with dynamic blocks
├── rds/              # RDS instance + parameter group + subnet group
└── root-example/     # Root module using all child modules
```

## Usage

```bash
cd root-example/
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```
