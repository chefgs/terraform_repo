# AWS – Terraform IaC Examples

Terraform code samples for **Amazon Web Services (AWS)** infrastructure provisioning.

## Directory Structure

```
aws/
├── create-ec2/          # Simple EC2 instance creation
├── web-tier/            # Web tier with VPC, subnets, security groups
├── web-tier-samples/    # Additional web tier variations
├── cloudfront/          # CloudFront CDN distribution
├── s3-dynamodb/         # S3 + DynamoDB (remote state backend pattern)
├── eks-samples/         # EKS cluster (self-managed & Fargate)
├── eks-module-demo/     # EKS using official AWS module
├── ec2-with-modules/    # EC2 with reusable modules pattern
├── elasticsearch/       # Elasticsearch/OpenSearch deployment
├── tf-code/             # Miscellaneous AWS resource examples
├── tf-modules-sample/   # Terraform module samples
├── iac-101/             # IaC fundamentals with AWS
├── sample/              # Quick-start AWS samples
└── demos/               # YouTube demo code
```

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.0.0 |
| AWS Provider | ~> 5.0 |
| AWS CLI | >= 2.0 |

## AWS Authentication

```bash
# Option 1: AWS CLI profile
aws configure --profile my-profile

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: IAM role (recommended for CI/CD)
# Configure in GitHub Actions secrets or EC2 instance profile
```

## Getting Started

```bash
# Navigate to any example
cd create-ec2/

# Initialize
terraform init

# Preview
terraform plan

# Deploy
terraform apply

# Destroy
terraform destroy
```
