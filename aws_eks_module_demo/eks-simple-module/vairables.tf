variable "region" {
  description = "The AWS region to deploy the EKS cluster"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "The availability zones to deploy the EKS cluster"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "The private subnets for the EKS cluster"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "The public subnets for the EKS cluster"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "instance_type" {
  description = "The instance type for the EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "The desired capacity for the EKS node group"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum capacity for the EKS node group"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "The minimum capacity for the EKS node group"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "The key name for SSH access to the nodes"
  type        = string
  default     = "my-key"
}

variable "is_admin" {
  description = "Boolean flag to indicate if the current user is an admin"
  type        = bool
  default     = false
}