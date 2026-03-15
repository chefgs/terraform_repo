variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "cluster_iam_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  type        = string
}

variable "node_group_iam_role_arn" {
  description = "EKS Node Group IAM Role ARN"
  type        = string
}

variable "key_name" {
  description = "Node group instance key"
  type = string
}