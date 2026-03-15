provider "aws" {
  region = var.region
}


module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr_block
  public_subnets = var.public_subnet_cidr_blocks
  private_subnets = var.private_subnet_cidr_blocks
}

data "aws_availability_zones" "available" {}

locals {
  availability_zones = data.aws_availability_zones.available.names
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "gs-eks-cluster"
  cluster_version = "1.25"
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets  # Add this line to provide subnet IDs

    # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
