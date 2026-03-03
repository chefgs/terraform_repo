# Elastic search domain name
variable "domain" {
  default = "gs-demo-es"
}

# AWS account id
variable "aws_account_id" {
  default = "123456789876"
}

# Region of the ES
variable "region" {
  default = "us-west-2"
}

# KMS Key ARN for Elasticsearch encryption
variable "kms_key_arn" {
  description = "KMS Key ARN for Elasticsearch encryption at rest"
  type        = string
  default     = ""
}

# VPC subnet IDs for Elasticsearch
variable "subnet_ids" {
  description = "Subnet IDs for Elasticsearch VPC config"
  type        = list(string)
  default     = []
}

# VPC security group IDs for Elasticsearch
variable "security_group_ids" {
  description = "Security group IDs for Elasticsearch VPC config"
  type        = list(string)
  default     = []
}

# CloudWatch log group ARN for Elasticsearch logs
variable "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN for Elasticsearch logs"
  type        = string
  default     = ""
}

# Master user name for Elasticsearch fine-grained access control
variable "master_user_name" {
  description = "Master user name for Elasticsearch fine-grained access control"
  type        = string
  sensitive   = true
}

# Master user password for Elasticsearch fine-grained access control
variable "master_user_password" {
  description = "Master user password for Elasticsearch fine-grained access control"
  type        = string
  sensitive   = true
}

# AWS account config
provider "aws" {
  region = var.region
}

# Terraform AWS ES Resource definition section
resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.domain
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = "t3.small.elasticsearch"
    instance_count = 3
    dedicated_master_enabled = true
    dedicated_master_type    = "t3.small.elasticsearch"
    dedicated_master_count   = 3
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  dynamic "vpc_options" {
    for_each = length(var.subnet_ids) > 0 && length(var.security_group_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.cloudwatch_log_group_arn != "" ? [1] : []
    content {
      cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
      log_type                 = "AUDIT_LOGS"
      enabled                  = true
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.cloudwatch_log_group_arn != "" ? [1] : []
    content {
      cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
      log_type                 = "INDEX_SLOW_LOGS"
      enabled                  = true
    }
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.aws_account_id}:root"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:${var.region}:${var.aws_account_id}:domain/${var.domain}/*"
    }
  ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Domain = "TestDomain"
  }
}
