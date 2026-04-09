---
layout: default
title: NVIDIA RAG Application
nav_order: 11
---

# NVIDIA RAG Application – IaC Deployment

[![AWS Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml/badge.svg)](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_aws.yml)

> **Path:** `nvidia/`  
> A self-contained, expandable example of deploying a GPU-accelerated
> **Retrieval-Augmented Generation (RAG)** document assistant using
> **NVIDIA NIM** inference microservices and Terraform.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Python RAG Application](#python-rag-application)
- [Terraform Infrastructure](#terraform-infrastructure)
- [NVIDIA NGC Provider Stub](#nvidia-ngc-provider-stub)
- [Quick Start](#quick-start)
- [Extending This Example](#extending-this-example)

---

## Overview

The `nvidia/` directory provides two things:

| Component | Path | Description |
|-----------|------|-------------|
| **Python RAG App** | `nvidia/rag-application/app/` | Interactive CLI that indexes PDF/TXT/DOCX documents into a FAISS vector store and answers questions using NVIDIA NIM LLMs |
| **Terraform IaC** | `nvidia/terraform/` | AWS GPU infrastructure — VPC, EC2 GPU instance, S3 bucket, IAM — plus commented NVIDIA NGC provider stubs |

The code is **intentionally stubbable**: `terraform plan` runs without real credentials, and the Python app can run locally without a GPU by pointing to the NVIDIA cloud API.

---

## Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────┐
│  AWS VPC  (10.0.0.0/16)                             │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │  Public Subnet (10.0.1.0/24)               │   │
│  │                                             │   │
│  │  ┌──────────────────────────────────────┐  │   │
│  │  │  EC2 GPU Instance  (g4dn.xlarge)     │  │   │
│  │  │  • NVIDIA T4 GPU  (16 GB VRAM)       │  │   │
│  │  │  • AWS Deep Learning AMI             │  │   │
│  │  │  • Python RAG Application            │  │   │
│  │  └──────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  S3 Bucket  (documents + FAISS index)               │
│  IAM Role   (least-privilege S3 access)             │
└─────────────────────────────────────────────────────┘
         │
         ▼  HTTPS API calls
  integrate.api.nvidia.com
  (NVIDIA NIM – LLM + Embeddings)
```

### Resources Created by Terraform

| Resource | Description |
|----------|-------------|
| `aws_vpc` | Dedicated VPC with DNS support |
| `aws_subnet` | Public subnet with auto-assign public IP |
| `aws_internet_gateway` | Internet gateway for outbound NIM API calls |
| `aws_security_group` | SSH (restricted CIDR) + application port |
| `aws_iam_role` | EC2 instance role with least-privilege S3 access |
| `aws_s3_bucket` | Versioned, encrypted bucket for documents and FAISS index |
| `aws_instance` | GPU EC2 instance (Deep Learning AMI, auto-resolved) |

---

## Python RAG Application

### Supported Document Formats

| Format | Extension | Loader |
|--------|-----------|--------|
| PDF | `.pdf` | `PyPDFLoader` |
| Plain text | `.txt` | `TextLoader` |
| Word (new) | `.docx` | `Docx2txtLoader` |
| Word (legacy) | `.doc` | `UnstructuredWordDocumentLoader` |

### How It Works

```
Document File
     │
     ▼
[DocumentProcessor]
  • Load via LangChain loader
  • Split into overlapping chunks (default: 1000 chars, 200 overlap)
     │
     ▼
[RAGEngine]
  • Embed chunks with NVIDIA nv-embedqa-e5-v5
  • Store in FAISS vector index
     │  (at query time)
     ▼
  • User question → retrieve top-k similar chunks
  • Feed chunks + question to meta/llama-3.1-8b-instruct via NIM
  • Return grounded answer with source references
```

### CLI Reference

```bash
# From the repo root
python nvidia/rag-application/app/main.py [OPTIONS]
```

| Flag | Default | Description |
|------|---------|-------------|
| `--file FILE` | *(required)* | Document to load (PDF/TXT/DOCX/DOC) |
| `--load-index DIR` | – | Load a previously saved FAISS index |
| `--save-index DIR` | – | Save the FAISS index after indexing |
| `--chunk-size N` | `1000` | Characters per document chunk |
| `--chunk-overlap N` | `200` | Overlap between adjacent chunks |
| `--top-k N` | `4` | Retrieved chunks per query |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NVIDIA_API_KEY` | – | NVIDIA NIM API key (get at [ngc.nvidia.com](https://ngc.nvidia.com/)) |
| `OPENAI_API_KEY` | – | OpenAI API key (used as fallback when `NVIDIA_API_KEY` is absent) |
| `LLM_MODEL` | `meta/llama-3.1-8b-instruct` | LLM model identifier |
| `EMBEDDING_MODEL` | `nvidia/nv-embedqa-e5-v5` | Embedding model identifier |
| `LLM_BASE_URL` | `https://integrate.api.nvidia.com/v1` | NIM endpoint base URL |

### Example Session

```
╔══════════════════════════════════════════════════════════════╗
║        NVIDIA RAG Document Assistant  (powered by NIM)      ║
║   Supports PDF · TXT · DOCX – Type 'exit' to quit           ║
╚══════════════════════════════════════════════════════════════╝

[DocumentProcessor] Loading PDF file: annual-report.pdf
[DocumentProcessor] Loaded 42 page(s)/section(s).
[DocumentProcessor] Split into 187 chunk(s) (chunk_size=1000, overlap=200).
[RAGEngine] Using NVIDIA NIM endpoint: https://integrate.api.nvidia.com/v1
[RAGEngine] Building FAISS index from 187 chunk(s)…
[RAGEngine] Index built and QA chain ready.

Document indexed and ready!  Ask your questions below.

You: What is the main conclusion of the report?
Assistant: The report concludes that revenue grew by 23% year-over-year…

[Sources: annual-report.pdf (page 4); annual-report.pdf (page 12)]

You: exit
Goodbye!
```

---

## Terraform Infrastructure

### Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `environment` | `dev` | Deployment environment label |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR |
| `instance_type` | `g4dn.xlarge` | EC2 GPU instance type |
| `ami_id` | *(auto-resolved)* | AMI ID — leave empty to use latest Deep Learning AMI |
| `key_pair_name` | – | EC2 key pair for SSH access |
| `ssh_allowed_cidr` | `0.0.0.0/0` | CIDR block allowed to reach port 22 |
| `app_port` | `8080` | Application API port |
| `root_volume_size_gb` | `100` | Root EBS volume size (GiB) |
| `rag_app_s3_bucket` | *(auto-generated)* | S3 bucket name |
| `nvidia_ngc_api_key` | – | NVIDIA NGC API key (sensitive) |
| `nvidia_nim_model` | `meta/llama-3.1-8b-instruct` | NIM LLM model |
| `nvidia_embedding_model` | `nvidia/nv-embedqa-e5-v5` | NIM embedding model |

### Outputs

| Output | Description |
|--------|-------------|
| `rag_instance_id` | EC2 instance ID |
| `rag_instance_public_ip` | Public IP of the GPU host |
| `rag_instance_public_dns` | Public DNS name |
| `rag_instance_ami` | Resolved AMI ID |
| `rag_app_url` | Application URL (`http://<ip>:<port>`) |
| `rag_docs_s3_bucket` | S3 bucket name |
| `rag_docs_s3_bucket_arn` | S3 bucket ARN |
| `iam_instance_role_arn` | IAM role ARN |
| `ssh_command` | Ready-to-use SSH command |
| `vpc_id` | VPC ID |
| `public_subnet_id` | Subnet ID |
| `security_group_id` | Security group ID |

### Deploying

```bash
cd nvidia/terraform

# 1. Initialise providers
terraform init

# 2. Review the plan (safe – no resources created)
terraform plan \
  -var="aws_region=us-east-1" \
  -var="key_pair_name=my-key" \
  -var="nvidia_ngc_api_key=nvapi-xxxx"

# 3. Apply
terraform apply \
  -var="aws_region=us-east-1" \
  -var="key_pair_name=my-key" \
  -var="nvidia_ngc_api_key=nvapi-xxxx"

# 4. Destroy when done
terraform destroy
```

Or use a `terraform.tfvars` file:

```hcl
aws_region             = "us-east-1"
environment            = "dev"
instance_type          = "g4dn.xlarge"
key_pair_name          = "my-key"
ssh_allowed_cidr       = "203.0.113.0/24"   # restrict to your IP in production
nvidia_ngc_api_key     = "nvapi-xxxxxxxxxxxx"
nvidia_nim_model       = "meta/llama-3.1-8b-instruct"
nvidia_embedding_model = "nvidia/nv-embedqa-e5-v5"
```

---

## NVIDIA NGC Provider Stub

The `providers.tf` and `main.tf` files contain **commented-out** blocks showing how the
[NVIDIA NGC Terraform provider](https://registry.terraform.io/providers/nvidia/ngc) integrates:

```hcl
# In providers.tf – activate by uncommenting:
# provider "nvidia" {
#   api_key = var.nvidia_ngc_api_key   # or NVIDIA_NGC_API_KEY env var
# }

# In main.tf – NGC resources (stub):
# resource "nvidia_ngc_registry_image" "rag_container" {
#   org_name    = "my-ngc-org"
#   image_name  = "rag-app"
#   is_public   = false
# }

# resource "nvidia_nim_endpoint" "llm" {
#   model   = var.nvidia_nim_model
#   api_key = var.nvidia_ngc_api_key
#   scaling { min_replicas = 1; max_replicas = 4 }
# }

# resource "nvidia_nim_endpoint" "embeddings" {
#   model   = var.nvidia_embedding_model
#   api_key = var.nvidia_ngc_api_key
#   scaling { min_replicas = 1; max_replicas = 2 }
# }
```

---

## Quick Start

### Run Locally (no GPU required)

```bash
# 1. Create virtualenv
python3 -m venv .venv && source .venv/bin/activate

# 2. Install dependencies
pip install -r nvidia/rag-application/app/requirements.txt

# 3. Export NVIDIA NIM key
export NVIDIA_API_KEY="nvapi-xxxxxxxxxxxxxxxxxxxx"

# 4. Chat with a document
python nvidia/rag-application/app/main.py --file /path/to/document.pdf
```

### Save & Reload an Index

```bash
# Index once and save
python nvidia/rag-application/app/main.py \
  --file report.pdf \
  --save-index ./report-index

# Reload later without re-indexing
python nvidia/rag-application/app/main.py \
  --load-index ./report-index
```

---

## Extending This Example

| Goal | Suggested Change |
|------|-----------------|
| API server | Replace CLI `main.py` with FastAPI; update systemd `ExecStart` in `bootstrap.sh` |
| Multi-document | Accept multiple `--file` args; merge chunks before indexing |
| Private networking | Move EC2 to private subnet + NAT gateway + ALB |
| Auto-scaling | Wrap instance in Auto Scaling Group with GPU-aware scaling |
| Kubernetes | Deploy on EKS + NVIDIA GPU Operator + NIM Helm chart |
| Cost optimisation | Use Spot instances (`aws_spot_instance_request`) for dev/test |
| Full NGC activation | Uncomment NGC provider + resource blocks in `providers.tf` / `main.tf` |

---

*[← Back to Cloud Providers](./cloud-providers.html)* | *[Next: Custom Providers →](./custom-provider.html)*
