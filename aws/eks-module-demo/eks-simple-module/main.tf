# Define the provider
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name                 = "eks-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
}

resource "random_id" "cluster_random_value" {
  byte_length = 4
}

# Create EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "20.10"
  cluster_name    = "${var.cluster_name}-${random_id.cluster_random_value.hex}"
  cluster_version = "1.30"
  subnet_ids         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # Create IAM Role for EKS Cluster
  cluster_endpoint_public_access = true
  cluster_enabled_log_types       = ["api", "audit", "authenticator"]

  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity
      instance_type    = var.instance_type
      key_name         = var.key_name
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = var.is_admin ? true : false
}

# Get the current user's ARN
data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "example" {
  cluster_name      =  module.eks.cluster_name
  principal_arn     = data.aws_caller_identity.current.arn
  # kubernetes_groups = ["group-1", "group-2"]
  type              = "STANDARD"
}

# resource "aws_eks_access_policy_association" "example" {
#  cluster_name  = module.eks.cluster_name
#  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#  principal_arn = data.aws_caller_identity.current.arn

#  access_scope {
#    namespaces = ["default", "kube-system"]
#    type       = "namespace"
#  }
#}

