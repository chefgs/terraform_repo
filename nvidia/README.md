# NVIDIA RAG Application – Infrastructure as Code

> 📚 **Documentation:** [Full docs on GitHub Pages](https://chefgs.github.io/terraform_repo/nvidia-rag/)

This directory contains a **stub / example** IaC deployment for a
Retrieval-Augmented Generation (RAG) document assistant powered by
**NVIDIA NIM** (inference microservices) and deployed on AWS GPU-accelerated
infrastructure using **Terraform**.

> **Note:** The code is intentionally stubbed so you can run `terraform plan`
> without real credentials and expand it incrementally.  The Python RAG
> application, however, is fully functional and can be run locally.

---

## Directory Structure

```
nvidia/
├── README.md                          ← this file
├── rag-application/
│   └── app/
│       ├── main.py                    ← interactive CLI entry point
│       ├── document_processor.py      ← PDF / TXT / DOCX loader & splitter
│       ├── rag_engine.py              ← FAISS vector store + LLM QA chain
│       └── requirements.txt           ← Python dependencies
└── terraform/
    ├── providers.tf                   ← AWS + NVIDIA NGC provider declarations
    ├── variables.tf                   ← all configurable parameters
    ├── main.tf                        ← VPC, EC2 GPU instance, S3, IAM, NGC stubs
    ├── outputs.tf                     ← useful post-apply values
    ├── scripts/
    │   └── bootstrap.sh               ← EC2 user_data: installs deps, starts app
    └── tests/                         ← Terraform unit tests (no cloud credentials needed)
        ├── networking.tftest.hcl      ← VPC, subnet, IGW, route table tests
        ├── security.tftest.hcl        ← security group ingress/egress tests
        ├── compute.tftest.hcl         ← IAM role + EC2 instance config tests
        └── storage.tftest.hcl         ← S3 encryption, versioning, public-access tests
```

---

## Python RAG Application

### What it does

| Capability | Details |
|---|---|
| **Document formats** | PDF (`.pdf`), plain text (`.txt`), Word (`.docx`, `.doc`) |
| **Embeddings** | NVIDIA `nv-embedqa-e5-v5` via NIM (falls back to OpenAI) |
| **LLM** | NVIDIA `meta/llama-3.1-8b-instruct` via NIM (falls back to OpenAI) |
| **Vector store** | [FAISS](https://github.com/facebookresearch/faiss) – CPU or GPU |
| **Interface** | Interactive terminal Q&A session |

### Quick start (local)

```bash
# 1. Create a virtual environment
python3 -m venv .venv && source .venv/bin/activate

# 2. Install dependencies
pip install -r nvidia/rag-application/app/requirements.txt

# 3. Set your NVIDIA NIM API key (get one at https://ngc.nvidia.com/)
export NVIDIA_API_KEY="nvapi-xxxxxxxxxxxxxxxxxxxx"

# 4. Run the assistant
python nvidia/rag-application/app/main.py --file /path/to/your/document.pdf
```

```
╔══════════════════════════════════════════════════════════════╗
║        NVIDIA RAG Document Assistant  (powered by NIM)      ║
║   Supports PDF · TXT · DOCX – Type 'exit' to quit           ║
╚══════════════════════════════════════════════════════════════╝

[DocumentProcessor] Loading PDF file: report.pdf
[DocumentProcessor] Loaded 42 page(s)/section(s).
[DocumentProcessor] Split into 187 chunk(s) (chunk_size=1000, overlap=200).
[RAGEngine] Building FAISS index from 187 chunk(s)…
[RAGEngine] Index built and QA chain ready.

Document indexed and ready!  Ask your questions below.

You: What is the main conclusion of the report?
Assistant: The main conclusion is …
```

### CLI options

| Flag | Default | Description |
|---|---|---|
| `--file FILE` | *(required)* | Document to load (PDF/TXT/DOCX) |
| `--load-index DIR` | – | Load a saved FAISS index instead of re-indexing |
| `--save-index DIR` | – | Persist the FAISS index after indexing |
| `--chunk-size N` | `1000` | Characters per document chunk |
| `--chunk-overlap N` | `200` | Overlap between adjacent chunks |
| `--top-k N` | `4` | Retrieved chunks per query |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `NVIDIA_API_KEY` | – | NVIDIA NIM API key (required for NIM endpoints) |
| `OPENAI_API_KEY` | – | OpenAI API key (used as fallback) |
| `LLM_MODEL` | `meta/llama-3.1-8b-instruct` | LLM model identifier |
| `EMBEDDING_MODEL` | `nvidia/nv-embedqa-e5-v5` | Embedding model identifier |
| `LLM_BASE_URL` | `https://integrate.api.nvidia.com/v1` | NIM endpoint base URL |

---

## Terraform Infrastructure

### Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────┐
│  AWS VPC  (10.0.0.0/16)                     │
│                                             │
│  ┌──────────────────────────────────┐       │
│  │  Public Subnet (10.0.1.0/24)    │       │
│  │                                  │       │
│  │  ┌──────────────────────────┐   │       │
│  │  │  EC2 GPU Instance        │   │       │
│  │  │  (g4dn.xlarge – T4 GPU) │   │       │
│  │  │                          │   │       │
│  │  │  NVIDIA RAG Application  │   │       │
│  │  └──────────────────────────┘   │       │
│  └──────────────────────────────────┘       │
│                                             │
│  S3 Bucket (documents + FAISS index)        │
└─────────────────────────────────────────────┘
         │
         ▼ (NVIDIA NIM API calls)
  integrate.api.nvidia.com
```

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.3 (≥ 1.7 for unit tests)
- AWS credentials configured (`aws configure` or environment variables)
- NVIDIA NGC API key (optional – for NIM endpoints)

### Deploy

```bash
cd nvidia/terraform

# Initialise providers
terraform init

# Review the plan (no real resources created until apply)
terraform plan \
  -var="aws_region=us-east-1" \
  -var="key_pair_name=my-key-pair" \
  -var="nvidia_ngc_api_key=nvapi-xxxx"

# Create infrastructure
terraform apply \
  -var="aws_region=us-east-1" \
  -var="key_pair_name=my-key-pair" \
  -var="nvidia_ngc_api_key=nvapi-xxxx"
```

Or create a `terraform.tfvars` file:

```hcl
aws_region             = "us-east-1"
environment            = "dev"
instance_type          = "g4dn.xlarge"
key_pair_name          = "my-key-pair"
nvidia_ngc_api_key     = "nvapi-xxxxxxxxxxxx"
nvidia_nim_model       = "meta/llama-3.1-8b-instruct"
nvidia_embedding_model = "nvidia/nv-embedqa-e5-v5"
```

### Outputs

After `terraform apply`:

| Output | Description |
|---|---|
| `rag_instance_id` | EC2 instance ID of the GPU host |
| `rag_instance_public_ip` | Public IP of the GPU host |
| `rag_instance_public_dns` | Public DNS name of the GPU instance |
| `rag_instance_ami` | Resolved AMI ID used for the GPU instance |
| `rag_app_url` | URL to the RAG application API |
| `rag_docs_s3_bucket` | S3 bucket name for documents |
| `rag_docs_s3_bucket_arn` | ARN of the S3 documents bucket |
| `iam_instance_role_arn` | ARN of the IAM role attached to the GPU instance |
| `ssh_command` | Ready-to-use SSH command |
| `vpc_id` | VPC ID |
| `public_subnet_id` | Public subnet ID |
| `security_group_id` | Security group ID |

### Destroy

```bash
terraform destroy
```

---

## Local Testing Without Cloud Credentials

Developers can validate and unit-test **the entire GPU infrastructure without
an AWS account or any cloud credentials**.  The tests use Terraform's built-in
[`mock_provider`](https://developer.hashicorp.com/terraform/language/tests/mocking)
feature (requires Terraform ≥ 1.7) to simulate every AWS API response locally.

### What is tested

| Test file | Resources covered |
|---|---|
| `tests/networking.tftest.hcl` | VPC CIDR, DNS settings, public subnet, IGW, route table default route |
| `tests/security.tftest.hcl` | SSH and RAG-API ingress rules, egress rules, custom port |
| `tests/compute.tftest.hcl` | GPU instance type, root volume encryption, IAM role/profile, AMI resolution |
| `tests/storage.tftest.hcl` | S3 AES-256 encryption, versioning, all four public-access-block settings |

### Run all unit tests locally (no AWS credentials needed)

```bash
# 1. Install Terraform 1.7+ (or use tfenv to manage versions)
brew install terraform          # macOS
# or download from https://developer.hashicorp.com/terraform/install

# 2. Initialise providers (downloads them but does NOT contact AWS)
cd nvidia/terraform
terraform init

# 3. Run every unit test
terraform test -verbose

# 4. Run a single test file
terraform test -filter=tests/networking.tftest.hcl -verbose
terraform test -filter=tests/security.tftest.hcl  -verbose
terraform test -filter=tests/compute.tftest.hcl   -verbose
terraform test -filter=tests/storage.tftest.hcl   -verbose
```

Expected output (no credentials required):

```
tests/networking.tftest.hcl... in progress
  run "vpc_cidr_and_dns"... pass
  run "vpc_name_tag"... pass
  run "public_subnet_config"... pass
  run "custom_vpc_cidr"... pass
  run "route_table_default_route"... pass
  run "igw_name_tag"... pass
tests/networking.tftest.hcl... tearing down
tests/networking.tftest.hcl... pass

tests/security.tftest.hcl... in progress
  run "sg_has_ssh_and_app_ingress"... pass
  ...
tests/security.tftest.hcl... pass

tests/compute.tftest.hcl... in progress
  run "default_gpu_instance_type"... pass
  ...
tests/compute.tftest.hcl... pass

tests/storage.tftest.hcl... in progress
  run "s3_versioning_enabled"... pass
  ...
tests/storage.tftest.hcl... pass

Success! 28 passed, 0 failed.
```

### How mock_provider works

```
┌─────────────────────────────────────────────────────────────┐
│  Developer machine / CI runner                              │
│                                                             │
│  terraform test                                             │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────┐       mock_provider "aws"                  │
│  │  .tftest.hcl│ ───►  • Returns fake IDs / IPs / ARNs     │
│  │  (test file)│       • No network calls to AWS            │
│  └─────────────┘       • No credentials needed              │
│       │                                                     │
│       ▼                                                     │
│  assert { condition = ... }   ← validates configuration     │
│  ✅ PASS / ❌ FAIL                                           │
└─────────────────────────────────────────────────────────────┘
```

Each `.tftest.hcl` file in `tests/` declares a `mock_provider "aws"` block
that intercepts every AWS API call and returns deterministic, pre-defined
values.  `terraform test` then runs `command = plan` against the mocked
provider and evaluates the `assert` blocks against the planned values.

### CI – GitHub Actions

The workflow `.github/workflows/tf_validate_nvidia.yml` runs automatically on
every push or pull request that touches `nvidia/terraform/**`.  It executes
`terraform init`, `terraform validate`, and `terraform test` on a standard
GitHub-hosted runner — **no AWS secrets are stored or used**.

---

The `providers.tf` and `main.tf` files contain commented-out resource blocks
that illustrate how the
[NVIDIA NGC Terraform provider](https://registry.terraform.io/providers/nvidia/ngc)
can be used to manage:

- **NGC Private Registry images** (`nvidia_ngc_registry_image`)
- **NIM microservice endpoints** (`nvidia_nim_endpoint`)
- **Scoped API keys** (`nvidia_ngc_api_key`)

Uncomment the relevant blocks in `providers.tf` and `main.tf` once you have
an NGC org and API key to expand this example.

---

## Extending This Example

| Goal | Suggested change |
|---|---|
| API server instead of CLI | Replace `main.py` with a FastAPI app; update the systemd `ExecStart` in `bootstrap.sh` |
| Multi-document support | Add a loop in `main.py` that accepts multiple `--file` arguments |
| Private networking | Move the EC2 instance to a private subnet; add a NAT gateway and an ALB |
| Auto-scaling | Wrap the EC2 instance in an Auto Scaling Group with GPU-aware scaling policies |
| Kubernetes | Deploy via an EKS cluster with the NVIDIA GPU Operator and NIM Helm chart |
| Cost optimisation | Use Spot instances (`aws_spot_instance_request`) for dev/test workloads |
