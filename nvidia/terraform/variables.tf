# =============================================================================
# variables.tf
#
# Input variables for the NVIDIA RAG infrastructure deployment.
# Override defaults using a terraform.tfvars file or -var flags.
# =============================================================================

# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region in which to deploy the RAG infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment label (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet that hosts the RAG instance."
  type        = string
  default     = "10.0.1.0/24"
}

# -----------------------------------------------------------------------------
# EC2 / GPU instance
# -----------------------------------------------------------------------------
variable "instance_type" {
  description = <<-EOT
    EC2 instance type. Choose a GPU-enabled type for optimal performance:
      g4dn.xlarge  – 1× NVIDIA T4  (16 GB VRAM) – good for inference
      g4dn.2xlarge – 1× NVIDIA T4  (32 GB VRAM)
      p3.2xlarge   – 1× NVIDIA V100 (16 GB VRAM)
      p4d.24xlarge – 8× NVIDIA A100 (40 GB VRAM each)
  EOT
  type        = string
  default     = "g4dn.xlarge"
}

variable "ami_id" {
  description = <<-EOT
    AMI for the GPU instance. Leave empty to auto-select the latest AWS Deep
    Learning Base OSS NVIDIA Driver GPU AMI (Amazon Linux 2) for the chosen
    region via a data source lookup. Set explicitly to pin a known-good AMI.
  EOT
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access. Leave empty to skip."
  type        = string
  default     = ""
}

variable "ssh_allowed_cidr" {
  description = <<-EOT
    CIDR block permitted to reach port 22 (SSH). Defaults to 0.0.0.0/0 for this
    stub example; restrict to your IP or corporate CIDR in production, or set to
    an empty string to disable SSH inbound rules entirely and use AWS SSM Session
    Manager instead.
  EOT
  type        = string
  default     = "0.0.0.0/0"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# Application
# -----------------------------------------------------------------------------
variable "app_port" {
  description = "TCP port on which the RAG application API server listens."
  type        = number
  default     = 8080
}

variable "rag_app_s3_bucket" {
  description = <<-EOT
    Name of the S3 bucket used to store uploaded documents and the FAISS index.
    Must be globally unique. Leave empty to auto-generate a name.
  EOT
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# NVIDIA NGC (stub – enable when using the NVIDIA provider)
# -----------------------------------------------------------------------------
variable "nvidia_ngc_api_key" {
  description = "NVIDIA NGC API key. Used by the NVIDIA provider (currently stubbed)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "nvidia_nim_model" {
  description = "NVIDIA NIM LLM model identifier used by the RAG application."
  type        = string
  default     = "meta/llama-3.1-8b-instruct"
}

variable "nvidia_embedding_model" {
  description = "NVIDIA NIM embedding model identifier used by the RAG application."
  type        = string
  default     = "nvidia/nv-embedqa-e5-v5"
}
