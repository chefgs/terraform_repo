# =============================================================================
# main.tf
#
# NVIDIA RAG Application – AWS Infrastructure
#
# Resources created
# -----------------
# 1. VPC + public subnet + internet gateway + route table
# 2. Security group  – allows SSH (22) and RAG app port (var.app_port)
# 3. IAM role + instance profile – least-privilege S3 access for the EC2 host
# 4. S3 bucket – stores uploaded documents and persisted FAISS index
# 5. EC2 GPU instance – runs the RAG application on NVIDIA T4 / V100 / A100
# 6. (Stub) NVIDIA NGC resources – placeholder for NGC provider expansion
#
# The EC2 user_data script:
#   • Installs Python 3.11, pip, NVIDIA drivers, and CUDA toolkit
#   • Clones this repo and installs the RAG application dependencies
#   • Starts the application as a systemd service
# =============================================================================

locals {
  bucket_name = var.rag_app_s3_bucket != "" ? var.rag_app_s3_bucket : (
    "nvidia-rag-app-${random_id.suffix.hex}"
  )
  name_prefix = "nvidia-rag"
  # Resolve AMI: prefer explicit variable; fall back to latest Deep Learning AMI
  resolved_ami = var.ami_id != "" ? var.ami_id : data.aws_ami.deep_learning.id
}

# Auto-discover the latest AWS Deep Learning Base GPU AMI (Amazon Linux 2)
# when var.ami_id is not explicitly provided.
data "aws_ami" "deep_learning" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Amazon Linux 2) *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# =============================================================================
# Networking
# =============================================================================

resource "aws_vpc" "rag_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.rag_vpc.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.rag_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rag_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Security Group
# =============================================================================

resource "aws_security_group" "rag_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for the NVIDIA RAG application host"
  vpc_id      = aws_vpc.rag_vpc.id

  # SSH access – restrict to a known CIDR (var.ssh_allowed_cidr) in production.
  # Consider using AWS SSM Session Manager and omitting this rule entirely.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # RAG application API – restrict to trusted consumers in production.
  ingress {
    description = "RAG App API"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg"
  }
}

# =============================================================================
# IAM – EC2 instance role with least-privilege S3 access
# =============================================================================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rag_instance_role" {
  name               = "${local.name_prefix}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${local.name_prefix}-instance-role"
  }
}

data "aws_iam_policy_document" "rag_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.rag_docs.arn,
      "${aws_s3_bucket.rag_docs.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "rag_s3_access" {
  name   = "${local.name_prefix}-s3-access"
  role   = aws_iam_role.rag_instance_role.id
  policy = data.aws_iam_policy_document.rag_s3_policy.json
}

resource "aws_iam_instance_profile" "rag_profile" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.rag_instance_role.name
}

# =============================================================================
# S3 Bucket – document and index storage
# =============================================================================

resource "aws_s3_bucket" "rag_docs" {
  bucket = local.bucket_name

  tags = {
    Name = local.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "rag_docs" {
  bucket = aws_s3_bucket.rag_docs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rag_docs" {
  bucket = aws_s3_bucket.rag_docs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "rag_docs" {
  bucket                  = aws_s3_bucket.rag_docs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================================
# EC2 GPU Instance
# =============================================================================

resource "aws_instance" "rag_gpu" {
  ami                    = local.resolved_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.rag_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.rag_profile.name
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    delete_on_termination = true
    encrypted             = true
  }

  # Bootstrap script: installs dependencies and starts the RAG application
  user_data = base64encode(templatefile(
    "${path.module}/scripts/bootstrap.sh",
    {
      s3_bucket              = local.bucket_name
      app_port               = var.app_port
      nvidia_api_key         = var.nvidia_ngc_api_key
      nvidia_nim_model       = var.nvidia_nim_model
      nvidia_embedding_model = var.nvidia_embedding_model
    }
  ))

  tags = {
    Name = "${local.name_prefix}-gpu-instance"
  }
}

# =============================================================================
# NVIDIA NGC Resources (stub)
#
# The blocks below illustrate how the NVIDIA NGC Terraform provider would be
# used to manage cloud GPU resources.  Uncomment and complete once you have
# activated the provider in providers.tf.
#
# Resources available in the NVIDIA NGC provider:
#   nvidia_ngc_registry_image   – manage private container images
#   nvidia_ngc_api_key          – manage scoped NGC API keys
#   nvidia_nim_endpoint         – deploy NIM microservice endpoints
# =============================================================================

# # -- NGC Private Registry Image (stub) --
# resource "nvidia_ngc_registry_image" "rag_container" {
#   org_name     = "my-ngc-org"
#   image_name   = "rag-app"
#   description  = "NVIDIA RAG Application container image"
#   is_public    = false
# }

# # -- NIM Endpoint for LLM Inference (stub) --
# resource "nvidia_nim_endpoint" "llm" {
#   model   = var.nvidia_nim_model
#   api_key = var.nvidia_ngc_api_key
#
#   scaling {
#     min_replicas = 1
#     max_replicas = 4
#   }
# }

# # -- NIM Endpoint for Embeddings (stub) --
# resource "nvidia_nim_endpoint" "embeddings" {
#   model   = var.nvidia_embedding_model
#   api_key = var.nvidia_ngc_api_key
#
#   scaling {
#     min_replicas = 1
#     max_replicas = 2
#   }
# }
