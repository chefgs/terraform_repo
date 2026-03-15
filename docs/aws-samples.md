---
layout: default
title: AWS Samples
nav_order: 2
---

# AWS Terraform Samples

This section covers all AWS infrastructure provisioning examples available in this repository, using Terraform's [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

---

## Table of Contents

- [Overview](#overview)
- [EC2 Instances](#ec2-instances)
- [EKS Clusters](#eks-clusters)
- [AWS Web Tier](#aws-web-tier)
- [CloudFront Distribution](#cloudfront-distribution)
- [S3 and DynamoDB Modules](#s3-and-dynamodb-modules)
- [Reusable Module Patterns](#reusable-module-patterns)
- [Running the Code](#running-the-code)

---

## Overview

The `aws/` directory contains production-ready Terraform examples for common AWS services. Each subdirectory is a self-contained Terraform project with variables, provider configuration, and resource definitions.

```
aws/
├── create_ec2/           # EC2 instance with user_data and conditional counts
├── eks_samples/          # EKS cluster provisioning
├── aws_cloudfront/       # CloudFront CDN distribution
├── s3-dynamodb-module/   # S3 bucket + DynamoDB using modules
├── sample/               # Minimal starter example
├── tf_modules_sample/    # Reusable module composition
├── iac-terraform-101/    # IaC introduction tutorial
└── es_deploy_indexing/   # Elasticsearch deployment and indexing
```

---

## EC2 Instances

**Path:** `aws/create-ec2/`

This example demonstrates core Terraform concepts for creating AWS EC2 instances:

### Key Features

- **Variables block** — Parameterize region, instance count, and conditional flags
- **Required providers** — Version-locked AWS provider declaration
- **Conditional resource counts** — Create one or multiple instances based on a variable flag
- **User data scripts** — Bootstrap EC2 instances at launch via `user_data`
- **Outputs** — Surface instance IDs and states after apply

### Example Code

```hcl
variable "instance_count_needed" {
  default = "false"
}

variable "instance_count" {
  default = 2
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  # Conditional count: 1 instance by default, or var.instance_count if enabled
  count = var.instance_count_needed ? var.instance_count : 1

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

output "instance_id" {
  description = "ID of the EC2 instance(s)"
  value       = aws_instance.app_server.*.id
}
```

### Terraform Concepts Illustrated

| Concept | Example |
|---------|---------|
| Variables with defaults | `variable "region" { default = "us-west-2" }` |
| Provider version constraints | `version = "~> 3.27"` |
| Conditional count | `count = var.flag ? var.count : 1` |
| User data | Inline bash script via heredoc |
| Splat expressions | `aws_instance.app_server.*.id` |

---

## EKS Clusters

**Path:** `aws/eks_samples/` and `aws_eks_module_demo/`

Terraform code for provisioning Amazon Elastic Kubernetes Service (EKS) clusters.

### aws_eks_module_demo subdirectories

| Directory | Description |
|-----------|-------------|
| `eks-from-official-module/` | Uses the official [terraform-aws-modules/eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module |
| `eks-from-own-module/` | Custom-built EKS module demonstrating module creation |
| `eks-simple-module/` | Minimal EKS cluster example |

### What is Provisioned

- EKS control plane and node groups
- VPC, subnets, and security groups
- IAM roles and policies for the cluster
- Kubeconfig output for `kubectl` access

---

## AWS Web Tier

**Path:** `aws/web-tier/`

A multi-tier web architecture example including:

- **Application Load Balancer (ALB)** — Distributes traffic to backend instances
- **Auto Scaling Group** — Dynamic scaling based on CPU/network metrics
- **Security Groups** — Layered network access control
- **Launch Template** — EC2 configuration template for ASG

---

## CloudFront Distribution

**Path:** `aws/aws_cloudfront/`

Terraform code for creating an AWS CloudFront CDN distribution:

- Origin configuration (S3 bucket or custom HTTP origin)
- Cache behavior settings
- SSL/TLS certificate association
- Geographic restriction options

---

## S3 and DynamoDB Modules

**Path:** `aws/s3-dynamodb-module/`

Demonstrates how to use Terraform modules for:

- **S3 bucket** — Static hosting, versioning, and lifecycle rules
- **DynamoDB table** — Common pattern for Terraform remote state locking

```hcl
# Using the module
module "s3_bucket" {
  source      = "./modules/s3"
  bucket_name = "my-terraform-state"
  versioning  = true
}

module "dynamodb_lock" {
  source     = "./modules/dynamodb"
  table_name = "terraform-state-lock"
}
```

---

## Reusable Module Patterns

**Path:** `aws/tf_modules_sample/` and `tf-ec2-with-modules/`

These examples demonstrate how to structure and call reusable Terraform modules:

### Module Structure

```
tf-ec2-with-modules/
└── terraform-project/
    ├── main.tf          # Root module calling child modules
    ├── variables.tf     # Input variables
    ├── outputs.tf       # Module outputs
    └── modules/
        └── ec2/         # Reusable EC2 module
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

### Benefits of Modules

- **DRY principle** — Write once, reuse across environments
- **Encapsulation** — Hide implementation details, expose clean interfaces
- **Versioning** — Pin module versions for stable deployments
- **Testing** — Test modules independently from root configurations

---

## Running the Code

### Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) >= 0.14.9
- [AWS CLI](https://aws.amazon.com/cli/) configured with your credentials
- Appropriate IAM permissions for the resources you want to create

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/chefgs/terraform_repo.git

# 2. Navigate to the example
cd terraform_repo/aws/create-ec2

# 3. Initialize Terraform (downloads the AWS provider)
terraform init

# 4. Preview changes
terraform plan

# 5. Apply the configuration
terraform apply

# 6. Clean up when done
terraform destroy
```

### Using GitHub Actions CI

You can validate and apply any example using the built-in [Terraform AWS Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml):

1. Go to **Actions** → **Terraform AWS Workflow**
2. Click **Run Workflow**
3. Enter the path to your example (e.g., `aws/create-ec2`)
4. Click **Run Workflow** to start the job

---

*[← Back to Home](./)* | *[Next: Kubernetes →](./kubernetes)*
