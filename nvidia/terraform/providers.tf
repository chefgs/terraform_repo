# =============================================================================
# providers.tf
#
# Declares all Terraform providers used in this NVIDIA RAG deployment example.
#
# Providers
# ---------
# 1. aws   – provisions the GPU-accelerated EC2 instance and supporting infra.
# 2. nvidia – (stubbed) represents the NVIDIA NGC Terraform provider for
#             managing NVIDIA GPU Cloud resources such as NGC registry entries,
#             GPU operator configurations, and NIM microservice deployments.
#             See: https://registry.terraform.io/providers/nvidia/ngc
#
# Note: The NVIDIA NGC provider block is illustrative. Substitute real
# credentials and resource definitions when expanding this example.
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    # NVIDIA NGC Terraform Provider (stub – expand as needed)
    # Uncomment and configure once you have an NGC API key.
    # nvidia = {
    #   source  = "nvidia/ngc"
    #   version = "~> 0.1"
    # }
  }
}

# ---------------------------------------------------------------------------
# AWS Provider
# ---------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "nvidia-rag-app"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ---------------------------------------------------------------------------
# NVIDIA NGC Provider (stub)
#
# When activated, this provider allows you to manage resources on NVIDIA GPU
# Cloud – e.g. NGC private registry images, NIM endpoints, and API catalogues.
#
# Required environment variables:
#   NVIDIA_NGC_API_KEY – API key generated at https://ngc.nvidia.com/
# ---------------------------------------------------------------------------
# provider "nvidia" {
#   api_key = var.nvidia_ngc_api_key   # or use NVIDIA_NGC_API_KEY env var
# }
