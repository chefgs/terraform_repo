terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile_name
}