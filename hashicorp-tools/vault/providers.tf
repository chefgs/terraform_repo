terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Vault provider – connects to the running Vault cluster
provider "vault" {
  address = var.vault_address
  token   = var.vault_root_token
}
