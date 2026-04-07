# Terraform IaC Repository – Multi-Cloud & HashiCorp Tools

A senior-engineer-level collection of **Terraform Infrastructure-as-Code** examples covering major cloud providers, IaC best practices, HashiCorp toolchain, and Terraform version references.

> 📖 **New here? Read the [Usage Guide](./USAGE.md) to get up and running fast.**

---

<p align="center">
  <img width="1020" height="580" src="https://github.com/user-attachments/assets/62ce301a-c07a-46c5-b6d5-9f02f775cc0b" alt="Terraform Multi-Cloud Diagram" />
</p>

---

**Table of Contents:**

- [Usage Guide](./USAGE.md) ← **Start here**
- [Project Status](#project-status)
- [Repository Structure](#repository-structure)
- [Information About This Project](#information-about-this-project)
- [Provider Summaries](#provider-summaries)
  - [AWS](#aws-examples)
  - [Azure](#azure-examples)
  - [GCP](#gcp-examples)
  - [Kubernetes](#kubernetes-examples)
  - [DigitalOcean](#digitalocean-examples)
  - [Oracle Cloud](#oracle-cloud-infrastructure-examples)
  - [NVIDIA RAG Application](#-nvidia-rag-application-highlight)
  - [HashiCorp Tools](#-hashicorp-tools-examples)
  - [Custom Providers](#-custom-terraform-providers)
  - [IaC Best Practices](#-iac-best-practices)
  - [Terraform Cloud](#-terraform-cloud-examples)
- [Contributing Guidelines](#read-before-you-start-contributing-to-this-repo)
- [Documentation](#good-to-have-create-documentation-to-list-down-resourcesmodulesproviders-output)
- [License](#license)

## Project Status

| Provider | CI Status |
|----------|-----------|
| **AWS** | [![Terraform AWS Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml) |
| **Azure** | [![Terraform Azure Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_azure.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_azure.yml) |
| **GCP** | [![Terraform GCP Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_gcp.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_gcp.yml) |
| **DigitalOcean** | [![Terraform DigitalOcean Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_digitalocean.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_digitalocean.yml) |
| **Oracle Cloud** | [![Terraform Oracle Cloud Validate](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_oraclecloud.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_validate_oraclecloud.yml) |
| **Kubernetes** | [![Kubernetes Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_k8s.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_k8s.yml) |
| **Security Scan** | [![Checkov Security Scan](https://github.com/chefgs/terraform_repo/actions/workflows/checkov_security_scan.yml/badge.svg?branch=main)](https://github.com/chefgs/terraform_repo/actions/workflows/checkov_security_scan.yml) |

> All provider workflows run `terraform init` + `terraform validate` on push/PR to their respective directories, ensuring code is always syntactically valid without requiring cloud credentials.

## Repository Structure

```
terraform_repo/
│
├── aws/                    # ☁️  AWS Terraform examples (EC2, EKS, CloudFront, S3, etc.)
├── azure/                  # ☁️  Azure Terraform examples (VMs, networking)
├── gcp/                    # ☁️  GCP Terraform examples (compute, VPC)
├── digitalocean/           # ☁️  DigitalOcean examples (Droplets, App Platform)
│   ├── create-vm/          #    └── Droplet (VM) creation
│   └── app-platform/       #    └── App Platform deployment from Git repository
├── oraclecloud/            # ☁️  Oracle Cloud examples (VCN, Compute)
│   ├── create-vcn/         #    └── Virtual Cloud Network creation
│   └── compute/            #    └── Full networking stack + compute instance
│
├── nvidia/                 # 🤖  NVIDIA – RAG application on GPU infrastructure
│   ├── rag-application/    #    └── Python RAG assistant (PDF/TXT/DOCX + NVIDIA NIM)
│   └── terraform/          #    └── AWS GPU EC2 + VPC + S3 + NVIDIA NGC provider stub
│
├── kubernetes/             # ⎈  Kubernetes resource management via Terraform
│
├── hashicorp-tools/        # 🔧  HashiCorp tool stack for 2-tier AWS app
│   ├── packer/             #    └── Golden AMI builder (web & app tier)
│   ├── vault/              #    └── Secrets management (dynamic creds, PKI)
│   ├── consul/             #    └── Service discovery & health checks
│   └── boundary/           #    └── Zero-trust access control
│
├── custom-providers/       # 🔨  Custom Terraform provider development (Go)
│   ├── basic/
│   ├── sdk-v2/
│   └── hashicups-pf/       #    └── Plugin Framework (recommended)
│
├── iac-best-practices/     # 📘  IaC best practices reference
│   ├── modules/            #    └── Modular resource creation patterns
│   ├── variables/          #    └── Variable templatization & locals
│   ├── testing/            #    └── Terraform native tests (.tftest.hcl)
│   └── lock-file-management/ #  └── Lock file strategy & multi-platform
│
├── terraform-versions/     # 📋  Version history & feature reference (v1.0–v1.14)
│
├── tfc-getting-started/    # 🏢  Terraform Cloud – getting started (pinned at root)
├── tfcloud_samples/        # 🏢  Terraform Cloud workflows & best practices (pinned at root)
│
└── docs/                   # 📚  Documentation site (GitHub Pages / Jekyll)
```

## Information about this project
- Idea for this open source repository is to collate the Terraform Resource Creation code for Major Cloud Providers, categorised by **cloud provider**, **IaC concepts**, and **HashiCorp tools**
- Includes examples for AWS, Azure, GCP, DigitalOcean, and Oracle Cloud Infrastructure
- Features a **NVIDIA RAG application** example — a Python document assistant powered by NVIDIA NIM LLM endpoints, deployed on AWS GPU infrastructure with full Terraform IaC (including a stubbed NVIDIA NGC provider)
- Demonstrates **Terraform best practices**: modular design, variable templatization, native testing, and lock file management
- Contains **HashiCorp full-stack** examples: Packer + Vault + Consul + Boundary for a production 2-tier AWS application
- Provides a **Terraform version reference guide** (v1.0–v1.14, latest: v1.14.7 Mar 2026) with code examples for every major release
- Also has sample code for *How to develop Terraform Custom Provider*
- Feel free to explore the repo content, and add :star: or fork if you like the content
- Repo is open for contributions and if you want to contribute please read the **important notice** for contribution guidelines

## Provider Summaries

### NVIDIA RAG Application Highlight

The [`nvidia/`](./nvidia/) directory provides a self-contained example of deploying a **Retrieval-Augmented Generation (RAG)** document assistant on NVIDIA GPU infrastructure:

| Component | Description |
|---|---|
| **Python RAG App** | Interactive CLI that loads PDF, TXT, or DOCX files and answers questions using NVIDIA NIM LLMs |
| **NVIDIA NIM** | Inference microservices for LLM (`meta/llama-3.1-8b-instruct`) and embeddings (`nv-embedqa-e5-v5`) |
| **FAISS Vector Store** | Local CPU/GPU vector index for fast similarity search |
| **Terraform IaC** | AWS VPC + GPU EC2 instance (`g4dn.xlarge`) + S3 bucket + IAM — all managed via Terraform |
| **NVIDIA NGC Provider** | Commented stub blocks ready to activate for NGC registry and NIM endpoint management |

```bash
# Run the RAG assistant locally
export NVIDIA_API_KEY="nvapi-..."
python nvidia/rag-application/app/main.py --file my-document.pdf
```

```bash
# Deploy the GPU infrastructure to AWS
cd nvidia/terraform && terraform init && terraform apply
```

### AWS Examples

The [`aws/`](./aws/) directory contains a wide range of **Amazon Web Services** infrastructure examples:

| Directory | Description |
|---|---|
| [`create-ec2/`](./aws/create-ec2/) | Simple EC2 instance creation |
| [`web-tier/`](./aws/web-tier/) | Web tier with VPC, subnets, and security groups |
| [`web-tier-samples/`](./aws/web-tier-samples/) | Additional web tier variations |
| [`cloudfront/`](./aws/cloudfront/) | CloudFront CDN distribution |
| [`s3-dynamodb/`](./aws/s3-dynamodb/) | S3 + DynamoDB remote state backend pattern |
| [`eks-samples/`](./aws/eks-samples/) | EKS cluster (self-managed & Fargate) |
| [`eks-module-demo/`](./aws/eks-module-demo/) | EKS using the official AWS module |
| [`ec2-with-modules/`](./aws/ec2-with-modules/) | EC2 with reusable modules pattern |
| [`elasticsearch/`](./aws/elasticsearch/) | Elasticsearch / OpenSearch deployment |
| [`iac-101/`](./aws/iac-101/) | IaC fundamentals with AWS |

```bash
# Example: deploy a simple EC2 instance
export AWS_DEFAULT_REGION="us-east-1"
cd aws/create-ec2/
terraform init && terraform apply
```

### Azure Examples

The [`azure/`](./azure/) directory contains **Microsoft Azure** infrastructure examples:

| Directory | Description |
|---|---|
| [`create-vm/`](./azure/create-vm/) | Create an Azure Virtual Machine with configurable size and networking |

```bash
# Authenticate with Azure CLI
az login
cd azure/create-vm/
terraform init && terraform apply
```

### GCP Examples

The [`gcp/`](./gcp/) directory contains **Google Cloud Platform** infrastructure examples:

| Directory | Description |
|---|---|
| [`resources/`](./gcp/resources/) | GCP resource creation — VPC, compute instances, and storage |

```bash
# Authenticate with GCP
gcloud auth application-default login
cd gcp/resources/
terraform init && terraform apply
```

### Kubernetes Examples

The [`kubernetes/`](./kubernetes/) directory demonstrates managing **Kubernetes resources** with Terraform using the Kubernetes provider:

| File / Resource | Description |
|---|---|
| `kubernetes_namespace` | Create and label a Kubernetes namespace |
| `kubernetes_resource_quota` | Enforce namespace-wide CPU, memory, and pod limits |
| `kubernetes_limit_range` | Set default resource requests/limits for containers |
| `kubernetes_deployment` | Deploy a containerized app with health checks and security context |
| `kubernetes_service` | Expose the deployment as a ClusterIP service |

```bash
# Prerequisites: running cluster with kubeconfig configured (e.g., Minikube)
cd kubernetes/
terraform init && terraform apply
kubectl get ns && kubectl get deployment -n <namespace>
```

### DigitalOcean Examples

The [`digitalocean/`](./digitalocean/) directory contains two examples:

| Directory | Description |
|---|---|
| [`create-vm/`](./digitalocean/create-vm/) | Create a DigitalOcean Droplet (VM) with configurable size, region, and OS image |
| [`app-platform/`](./digitalocean/app-platform/) | Deploy an application from a Git repository using App Platform, with project-level Git variable support for secret injection |

```bash
# Deploy the App Platform example
export TF_VAR_do_token="dop_v1_..."
cd digitalocean/app-platform/
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

### Oracle Cloud Infrastructure Examples

The [`oraclecloud/`](./oraclecloud/) directory contains two examples:

| Directory | Description |
|---|---|
| [`create-vcn/`](./oraclecloud/create-vcn/) | Create an OCI Virtual Cloud Network (VCN) with subnets and routing |
| [`compute/`](./oraclecloud/compute/) | Full free-tier infrastructure stack — VCN, internet gateway, route table, security list, and a flexible compute instance (`VM.Standard.E4.Flex`) |

```bash
# Deploy the OCI compute example
oci setup config          # configure OCI CLI and API key
cd oraclecloud/compute/
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
terraform output ssh_command   # get the ready-to-use SSH command
```

### 🔧 HashiCorp Tools Examples

The [`hashicorp-tools/`](./hashicorp-tools/) directory demonstrates the **full HashiCorp stack** for a production 2-tier AWS application:

| Directory | Description |
|---|---|
| [`terraform/`](./hashicorp-tools/terraform/) | Core AWS infrastructure — VPC, ALB, Auto Scaling Groups, and RDS PostgreSQL |
| [`packer/`](./hashicorp-tools/packer/) | Golden AMI builder for web and app tiers |
| [`vault/`](./hashicorp-tools/vault/) | Secrets management — dynamic credentials, PKI certificates, DB credentials |
| [`consul/`](./hashicorp-tools/consul/) | Service discovery, health checks, and KV store |
| [`boundary/`](./hashicorp-tools/boundary/) | Zero-trust access control to private resources |

```bash
# Deploy in order: Packer → Terraform → Vault → Consul → Boundary
cd hashicorp-tools/packer/ && packer build web-tier.pkr.hcl
cd ../terraform/           && terraform init && terraform apply
```

### 🔨 Custom Terraform Providers

The [`custom-providers/`](./custom-providers/) directory contains examples for **developing custom Terraform providers** in Go:

| Directory | Description |
|---|---|
| [`basic/`](./custom-providers/basic/) | Basic custom provider using the original SDK style |
| [`sdk-v2/`](./custom-providers/sdk-v2/) | Provider using Terraform Plugin SDK v2 |
| [`hashicups-pf/`](./custom-providers/hashicups-pf/) | HashiCups provider using the Terraform Plugin Framework (recommended) |
| [`example-provider/`](./custom-providers/example-provider/) | Production-quality example provider with tests and documentation |

```bash
# Build and test the Plugin Framework example
cd custom-providers/hashicups-pf/
go mod download
make build && make test
```

### 📘 IaC Best Practices

The [`iac-best-practices/`](./iac-best-practices/) directory is a reference collection covering key Terraform engineering patterns:

| Directory | Topic |
|---|---|
| [`modules/`](./iac-best-practices/modules/) | Modular, reusable, and composable resource creation patterns |
| [`variables/`](./iac-best-practices/variables/) | Variable templatization — types, validation blocks, and `locals` |
| [`testing/`](./iac-best-practices/testing/) | Terraform native tests using `.tftest.hcl` (requires Terraform v1.6+) |
| [`lock-file-management/`](./iac-best-practices/lock-file-management/) | Lock file strategy and multi-platform provider locking |

### 🏢 Terraform Cloud Examples

The repository includes two Terraform Cloud directories pinned at the root:

| Directory | Description |
|---|---|
| [`tfc-getting-started/`](./tfc-getting-started/) | Introductory example for connecting a local configuration to a Terraform Cloud workspace |
| [`tfcloud_samples/`](./tfcloud_samples/) | Terraform Cloud workflow patterns — remote runs, variable sets, and workspace best practices |

```bash
# Authenticate with Terraform Cloud
terraform login
cd tfc-getting-started/
terraform init && terraform apply
```

## Read before you start contributing to this repo
- Read [Contribution Guidelines](./CONTRIBUTING.md) before contributing to this repository!

- Read GitHub [Code Of Conduct guidelines](./CODE_OF_CONDUCT.md)before contributing to this repository!

- Feel free to pick up any of the open [Issues](https://github.com/chefgs/terraform_repo/issues) or create new issue using the [template](https://github.com/chefgs/terraform_repo/issues/new/choose)!

- This repo also has GitHub action [Terraform AWS workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation.yml) to check the Terraform AWS resource code is valid and works fine. Please utilize it for checking the terraform code you're creating. All you've to do is,
  - Open Workflow in "Actions" Tab
  - Click on `Run Workflow`
  - Choose you `branch_name` and Enter your `tf file path` on which you want to run the workflow
  - Check if the workflow is passing or not. Fix the issue in case of failure.

### Good to Have: Create documentation to list down resources/modules/providers/output
- Please install [`terraform-docs`](https://github.com/terraform-docs/terraform-docs/#what-is-terraform-docs) CLI utility to generate documentation for Terraform Code.
- After installing the utility, please run the below command to create markdown document
```
terraform-docs markdown table --output-file TF_README.md --output-mode inject <your-terraform-code-directory>
```
- Please use below command for generating docs recursively for all the Terraform code modules
```
~/go/bin/terraform-docs markdown table --output-file TF_README.md --recursive --recursive-path "<terraform-code-module-path>" --output-mode inject .
```

### Note: 
I've renamed the default branch from `master` to `main`. So If you've cloned my repo locally, then please follow the steps mentioned in [this document](https://dev.to/chefgs/git-101-rename-default-branch-from-master-to-main-5bf4#steps-to-rename-the-other-users-local-repo) to rename your local repo from `master` to `main`

- Feel free to browse through the branch and [post](mailto:g.gsaravanan@gmail.com) any questions to me.
- [LinkedIn](https://www.linkedin.com/in/saravanan-gnanaguru-1941a919/) - Saravanan Gnanaguru

:computer: Happy contributing to the Community!!

**Repo contributors profile link**

<a href="https://github.com/chefgs/terraform_repo/graphs/contributors">
 <img src="https://contrib.rocks/image?repo=chefgs/terraform_repo" />
</a>
