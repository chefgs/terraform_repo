# Usage Guide – Terraform IaC Repository

> **Who is this for?**  
> Cloud engineers and small cloud teams who want to adopt Infrastructure-as-Code without starting from scratch. This repo gives you working, validated examples you can copy, adapt, and ship — so you spend time on your infrastructure, not on boilerplate.

---

## Why This Repo Exists

IaC adoption stalls for the same reasons in every team:

- *"I don't know where to start"* — too many providers, too many opinions
- *"Our code works locally but breaks in CI"* — no validated patterns to follow
- *"We copy-paste and hope"* — no modular, reusable structure
- *"We don't know which Terraform version to use"* — unclear upgrade path

This repo fixes all of that. Every example is validated in CI, follows best practices, and is ready to fork.

---

## Prerequisites

Install these tools before you begin:

| Tool | Install | Minimum Version |
|------|---------|-----------------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | `brew install terraform` / `tfenv install` | v1.6+ |
| [Git](https://git-scm.com/downloads) | bundled on most systems | any |
| Cloud CLI (optional) | see provider section below | any |
| [tfenv](https://github.com/tfutils/tfenv) *(recommended)* | `brew install tfenv` | any |

> **Tip:** Use `tfenv` or `asdf` to switch between Terraform versions painlessly. The repo covers v1.0–v1.14.

---

## Quick Start — 3 Steps

```bash
# 1. Clone the repo
git clone https://github.com/chefgs/terraform_repo.git
cd terraform_repo

# 2. Pick any example and navigate to it
cd aws/create-ec2    # or azure/, gcp/, digitalocean/, etc.

# 3. Init and validate (no credentials needed for validation)
terraform init
terraform validate
```

That's it. Every directory with `.tf` files follows the same three-command pattern.

---

## Provider Guides

### ☁️ AWS

```bash
# Configure credentials (once)
aws configure          # enter Access Key ID, Secret, region

cd aws/create-ec2/
terraform init
terraform plan         # review what will be created
terraform apply        # type 'yes' to deploy
terraform destroy      # tear down when done
```

**What's available in `aws/`:**

| Directory | What It Creates |
|-----------|----------------|
| `create-ec2/` | EC2 instance with security group |
| `eks-module-demo/` | EKS cluster via community module |
| `cloudfront/` | CloudFront distribution + S3 origin |
| `s3-dynamodb/` | S3 bucket + DynamoDB table (state backend pattern) |
| `web-tier/` | Full web tier — ALB + ASG + EC2 |
| `hashicorp-tools/` | Packer + Vault + Consul + Boundary stack |

---

### ☁️ Azure

```bash
az login               # authenticate with Azure CLI

cd azure/
terraform init
terraform plan
terraform apply
```

---

### ☁️ GCP

```bash
gcloud auth application-default login

cd gcp/
terraform init
terraform plan
terraform apply
```

---

### ☁️ DigitalOcean

```bash
export TF_VAR_do_token="dop_v1_..."   # your DO API token

cd digitalocean/app-platform/
cp terraform.tfvars.example terraform.tfvars   # fill in your values
terraform init && terraform apply
```

| Directory | What It Creates |
|-----------|----------------|
| `create-vm/` | Droplet (VM) with configurable region, size, OS |
| `app-platform/` | App Platform deployment wired to a Git repository |

---

### ☁️ Oracle Cloud (OCI)

```bash
oci setup config       # generates ~/.oci/config + API key pair

cd oraclecloud/compute/
cp terraform.tfvars.example terraform.tfvars   # fill in tenancy OCID etc.
terraform init && terraform apply
terraform output ssh_command   # ready-to-use SSH command
```

| Directory | What It Creates |
|-----------|----------------|
| `create-vcn/` | Virtual Cloud Network with subnets |
| `compute/` | Free-tier VM + full network stack (VCN, IGW, route table) |

---

### ⎈ Kubernetes

```bash
# Assumes a running cluster (local or cloud)
export KUBECONFIG=~/.kube/config

cd kubernetes/
terraform init && terraform apply
```

---

### 🤖 NVIDIA / RAG Application

```bash
# Run the RAG document assistant locally
export NVIDIA_API_KEY="nvapi-..."
python nvidia/rag-application/app/main.py --file my-document.pdf

# Deploy GPU infrastructure on AWS
cd nvidia/terraform/
terraform init && terraform apply
```

Supports PDF, TXT, and DOCX files. Answers questions using NVIDIA NIM LLMs on a `g4dn.xlarge` GPU instance.

---

## IaC Best Practices

The `iac-best-practices/` directory is your reference for writing production-quality Terraform.

### Use Modules

```bash
cd iac-best-practices/modules/
```

- Break infrastructure into small, reusable modules
- Each module has its own `variables.tf`, `outputs.tf`, and `main.tf`
- Call modules from a root module — never put everything in one file

### Templatize Variables

```bash
cd iac-best-practices/variables/
```

- Never hardcode values — use `variables.tf` with descriptions and defaults
- Mark secrets with `sensitive = true`
- Use `locals` for derived values to avoid repetition

### Test Your Code

```bash
cd iac-best-practices/testing/
terraform test   # requires Terraform v1.6+
```

- Write `.tftest.hcl` files alongside your code
- Use `mock_provider` (v1.7+) to test without real cloud accounts
- Test both the happy path and edge cases

### Manage Lock Files

```bash
cd iac-best-practices/lock-file-management/
```

- **Always commit** `.terraform.lock.hcl` — it pins provider versions for the whole team
- Run `terraform providers lock -platform=linux_amd64 -platform=darwin_arm64` to support all platforms
- Never manually edit the lock file

---

## Terraform Cloud (TFC)

Use the TFC examples if you want remote state, team collaboration, and policy enforcement.

```bash
cd tfc-getting-started/
# Follow the README — you'll need a free app.terraform.io account
```

```bash
cd tfcloud_samples/
# Workspace, variable set, and VCS-driven workflow examples
```

---

## Terraform Version Reference

Not sure which version to use or what changed between releases?

```bash
ls terraform-versions/    # v1.0 through v1.14
cat terraform-versions/v1.14/CHANGELOG.md
```

- Each version directory has a `CHANGELOG.md` and working code examples
- Latest stable: **v1.14.7** (March 2026)
- Upgrade path and examples live in each version's `upgrade-guide.md`

To switch versions locally:

```bash
tfenv install 1.14.7 && tfenv use 1.14.7
# or
asdf install terraform 1.14.7 && asdf global terraform 1.14.7
```

---

## Custom Terraform Providers

Want to build your own provider? Start here:

```bash
cd custom-providers/hashicups-pf/   # Plugin Framework (recommended, Go)
```

The `basic/` and `sdk-v2/` directories show the older SDKv2 approach. Use `hashicups-pf` as your starting point.

---

## Validate Without Cloud Credentials

Every example can be syntax-checked locally and in CI without real credentials:

```bash
terraform init
terraform validate
terraform fmt -check   # checks formatting
```

The repo's GitHub Actions workflows do exactly this on every push and PR. You can also trigger them manually from the **Actions** tab with your branch name and a specific file path.

---

## Common Patterns

### Copy and Adapt

1. Find an example close to what you need (e.g., `aws/create-ec2/`)
2. Copy the directory into your own project
3. Edit `variables.tf` to match your requirements
4. Run `terraform plan` to review before applying

### State Backend

For team use, store state remotely. The `aws/s3-dynamodb/` example shows how to set up an S3 + DynamoDB backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
  }
}
```

### Environment Separation

Use separate `.tfvars` files per environment:

```bash
terraform apply -var-file="envs/dev.tfvars"
terraform apply -var-file="envs/prod.tfvars"
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `terraform init` fails | Check your internet connection; run `terraform init -upgrade` to refresh providers |
| `Error: No valid credential sources` | Run your cloud CLI login command (e.g., `aws configure`, `az login`) |
| Plan shows unexpected changes | Run `terraform refresh` then `plan` again; check for drift |
| Lock file conflict | Run `terraform providers lock` with all required platforms |
| Version mismatch | Use `tfenv use <version>` to match the version used in the example |
| `terraform validate` passes but `apply` fails | Usually a missing variable or IAM permission — check the error message carefully |

---

## Getting Help

- Browse [open issues](https://github.com/chefgs/terraform_repo/issues) — your question may already be answered
- Open a new issue using the [issue template](https://github.com/chefgs/terraform_repo/issues/new/choose)
- Read [CONTRIBUTING.md](./CONTRIBUTING.md) if you want to improve the repo

---

:rocket: **Start with one example. Get it working. Then build from there.**
