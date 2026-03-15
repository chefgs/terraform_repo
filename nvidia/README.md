# NVIDIA RAG Application – Infrastructure as Code

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
    └── scripts/
        └── bootstrap.sh               ← EC2 user_data: installs deps, starts app
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

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.3
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
| `rag_instance_public_ip` | Public IP of the GPU host |
| `rag_app_url` | URL to the RAG application API |
| `rag_docs_s3_bucket` | S3 bucket name for documents |
| `ssh_command` | Ready-to-use SSH command |

### Destroy

```bash
terraform destroy
```

---

## NVIDIA NGC Provider (stub)

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
