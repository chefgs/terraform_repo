variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "2tier-app"
}

variable "vpc_id" {
  description = "VPC ID where Consul will be deployed."
  type        = string
}

variable "consul_ami_id" {
  description = "AMI ID for Consul servers (built by Packer with Consul pre-installed)."
  type        = string
}

variable "consul_instance_type" {
  type    = string
  default = "t3.small"
}

variable "consul_server_count" {
  description = "Number of Consul servers (use 3 or 5 for production quorum)."
  type        = number
  default     = 3
}

variable "consul_version" {
  type    = string
  default = "1.18.1"
}

variable "consul_datacenter" {
  type    = string
  default = "dc1"
}
