---
layout: default
title: Home
nav_order: 1
---

# Terraform Code Repository

[![AWS Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml/badge.svg)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml)
[![Kubernetes Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_k8s.yml/badge.svg)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_k8s.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> An open-source collection of Terraform infrastructure-as-code examples for major cloud providers, Kubernetes, and custom provider development — complete with GitHub Actions CI/CD workflows.

---

## 📋 Table of Contents

- [About This Project](#about-this-project)
- [Repository Structure](#repository-structure)
- [Cloud Provider Samples](#cloud-provider-samples)
- [GitHub Actions Workflows](#github-actions-workflows)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

---

## About This Project

This repository is a curated collection of **Terraform** infrastructure-as-code examples covering:

- **Multi-cloud resource provisioning** — AWS, Azure, GCP, DigitalOcean, and Oracle Cloud
- **Kubernetes** deployments managed via the Terraform Kubernetes provider
- **Custom Terraform provider** development tutorials
- **Terraform Cloud** integration samples
- **CI/CD automation** using GitHub Actions

Whether you are learning Terraform for the first time or looking for real-world reference architectures, this repository provides practical, working examples you can adapt to your own infrastructure needs.

### Why Terraform?

[Terraform](https://www.terraform.io/) by HashiCorp is the leading open-source Infrastructure as Code (IaC) tool. Key benefits include:

| Feature | Description |
|---------|-------------|
| **Declarative HCL syntax** | Describe the desired state; Terraform figures out how to get there |
| **Multi-cloud** | One tool to manage AWS, Azure, GCP, and hundreds of other providers |
| **Execution plan** | Preview changes with `terraform plan` before applying them |
| **State management** | Track deployed infrastructure for safe incremental updates |
| **Modules** | Reusable, composable infrastructure building blocks |
| **Large ecosystem** | Thousands of providers and community modules |

---

## Repository Structure

```
terraform_repo/
├── aws_samples/              # AWS resource provisioning examples
│   ├── create_ec2/           # EC2 instance creation
│   ├── eks_samples/          # Amazon EKS cluster
│   ├── aws_cloudfront/       # CloudFront distribution
│   ├── s3-dynamodb-module/   # S3 + DynamoDB modules
│   └── tf_modules_sample/    # Reusable module examples
├── aws_eks_module_demo/      # EKS using official and custom modules
├── aws_web_tier/             # AWS web tier architecture
├── azure_samples/            # Azure VM and resource examples
├── gcp_samples/              # Google Cloud Platform examples
├── digitalocean_samples/     # DigitalOcean VM examples
├── oraclecloud_samples/      # Oracle Cloud Infrastructure examples
├── kubernetes/               # Kubernetes resources via Terraform
├── custom_provider/          # Custom Terraform provider development
├── terraform-provider-example/   # Provider SDK v1 example
├── terraform-provider-hashicups-pf/  # Provider Plugin Framework example
├── tf-ec2-with-modules/      # EC2 using Terraform modules
├── tfc-getting-started/      # Terraform Cloud getting started
├── tfcloud_samples/          # Terraform Cloud workspace examples
├── youtube_tf_demo/          # Demo code from YouTube tutorials
└── .github/workflows/        # GitHub Actions CI/CD workflows
```

---

## Cloud Provider Samples

### ☁️ [AWS Samples](./aws-samples)

Terraform code for provisioning AWS infrastructure:

- **EC2 Instances** — Create and manage virtual machines with conditional resource counts, user_data scripts, and tagging
- **EKS Clusters** — Amazon Elastic Kubernetes Service using official and custom modules
- **Web Tier Architecture** — Load balancers, auto-scaling groups, and security groups
- **CloudFront** — CDN distribution configuration
- **S3 + DynamoDB** — State backend and NoSQL database modules
- **Reusable Modules** — Patterns for creating shareable infrastructure modules

### ☁️ [Kubernetes](./kubernetes)

Terraform-managed Kubernetes resources using the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs):

- Namespace creation with labels and annotations
- Resource quotas and limit ranges
- Deployments with security contexts and health probes
- Services (ClusterIP, NodePort)
- Integration with Minikube, EKS, AKS, and GKE

### ☁️ [Multi-Cloud Samples](./cloud-providers)

- **Azure** — Virtual machine provisioning on Microsoft Azure
- **GCP** — Google Cloud Platform resource examples
- **DigitalOcean** — Droplet (VM) creation on DigitalOcean
- **Oracle Cloud** — OCI resource provisioning

### 🔌 [Custom Terraform Providers](./custom-provider)

Step-by-step guides for building your own Terraform provider:

- Terraform Plugin SDK v1 example
- Terraform Plugin SDK v2 example
- Terraform Plugin Framework (hashicups) example

### ☁️ [Terraform Cloud](./terraform-cloud)

Integration examples for [Terraform Cloud (TFC)](https://app.terraform.io/):

- Remote backend configuration
- Workspace management
- GitHub Actions integration with TFC API

---

## GitHub Actions Workflows

This repository includes automated [GitHub Actions workflows](./github-actions) for CI/CD:

| Workflow | Trigger | Description |
|----------|---------|-------------|
| [Terraform AWS Workflow](.github/workflows/tf_code_validation_aws.yml) | Push, PR, Manual | Validates and applies AWS Terraform code |
| [Terraform Kubernetes Workflow](.github/workflows/tf_code_validation_k8s.yml) | Push, PR, Manual | Deploys Kubernetes resources via Terraform |
| [TF Cloud AWS Workflow](.github/workflows/tf_cloud_aws.yml) | Push, PR, Manual | Runs Terraform plans via Terraform Cloud |
| [GitHub Pages](.github/workflows/pages.yml) | Push to main | Builds and deploys this documentation site |

---

## Getting Started

### Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads) (>= 0.14.9 recommended)
- Cloud provider CLI tools (AWS CLI, Azure CLI, gcloud, etc.)
- Appropriate cloud credentials configured

### Quick Start

1. **Clone the repository:**

   ```bash
   git clone https://github.com/chefgs/terraform_repo.git
   cd terraform_repo
   ```

2. **Navigate to any example directory:**

   ```bash
   cd aws_samples/create_ec2
   ```

3. **Initialize Terraform:**

   ```bash
   terraform init
   ```

4. **Review the plan:**

   ```bash
   terraform plan
   ```

5. **Apply the configuration:**

   ```bash
   terraform apply
   ```

6. **Clean up resources:**

   ```bash
   terraform destroy
   ```

### Generating Documentation

Install [`terraform-docs`](https://github.com/terraform-docs/terraform-docs/) to auto-generate documentation from your Terraform code:

```bash
# For a single module
terraform-docs markdown table --output-file TF_README.md --output-mode inject <your-terraform-code-directory>

# Recursively for all modules
~/go/bin/terraform-docs markdown table --output-file TF_README.md --recursive --recursive-path "<path>" --output-mode inject .
```

---

## Contributing

We welcome contributions! Please read the following before contributing:

- 📋 [Contribution Guidelines](https://github.com/chefgs/terraform_repo/blob/main/CONTRIBUTING.md)
- 📜 [Code of Conduct](https://github.com/chefgs/terraform_repo/blob/main/CODE_OF_CONDUCT.md)
- 🐛 [Open Issues](https://github.com/chefgs/terraform_repo/issues)

### How to Use the CI Workflow for Your Contribution

1. Open the [Actions tab](https://github.com/chefgs/terraform_repo/actions) in GitHub
2. Click on **Terraform AWS Workflow**
3. Click **Run Workflow**, choose your branch, and enter the path to your Terraform code
4. Verify the workflow passes before submitting a PR

---

## License

This project is licensed under the [MIT License](https://github.com/chefgs/terraform_repo/blob/main/LICENSE).

---

## Contributors

<a href="https://github.com/chefgs/terraform_repo/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=chefgs/terraform_repo" alt="Contributors" />
</a>

---

*Made with ❤️ by [Saravanan Gnanaguru](https://www.linkedin.com/in/saravanan-gnanaguru-1941a919/) and the open-source community.*
