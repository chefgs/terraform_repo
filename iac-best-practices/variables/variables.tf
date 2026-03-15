##############################################################################
# Terraform Variable Best Practices – Comprehensive Reference
#
# This file demonstrates all variable types, validation patterns,
# and best practices for enterprise Terraform codebases.
##############################################################################

# ── Primitive Types ────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region for resource deployment."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must be a valid AWS region identifier (e.g. us-east-1)."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create (1–10)."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count must be between 1 and 10."
  }
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring on EC2 instances."
  type        = bool
  default     = false
}

# ── String Enumerations ────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^(t[23]|m[456]|c[56]|r[456]|p[234])\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge)$", var.instance_type))
    error_message = "instance_type must be a valid EC2 instance type."
  }
}

# ── Collections ────────────────────────────────────────────────────────────

variable "availability_zones" {
  description = "List of AWS Availability Zones to spread resources across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 1
    error_message = "At least one availability zone must be specified."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application (e.g. office IPs)."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrnetmask(cidr))
    ])
    error_message = "All entries in allowed_cidr_blocks must be valid CIDR notation."
  }
}

# ── Map Types ─────────────────────────────────────────────────────────────

variable "common_tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Owner     = "platform-team"
  }
}

variable "instance_type_per_env" {
  description = "Map of environment → instance type for environment-specific sizing."
  type        = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

# ── Object Types ──────────────────────────────────────────────────────────

variable "database" {
  description = "Database configuration object."
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    storage_gb     = number
    multi_az       = bool
    backup_days    = number
  })
  default = {
    engine         = "postgres"
    engine_version = "16.1"
    instance_class = "db.t3.micro"
    storage_gb     = 20
    multi_az       = false
    backup_days    = 7
  }

  validation {
    condition     = var.database.backup_days >= 1 && var.database.backup_days <= 35
    error_message = "database.backup_days must be between 1 and 35."
  }
}

# ── Optional Object Attributes (Terraform 1.3+) ───────────────────────────

variable "scaling_config" {
  description = "Auto Scaling configuration with optional override values."
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = optional(number)    # defaults to null
    cooldown_seconds = optional(number, 300) # defaults to 300
  })
  default = {
    min_size = 1
    max_size = 3
  }
}

# ── Sensitive Variables ────────────────────────────────────────────────────

variable "db_password" {
  description = "Master password for the RDS database. Set via TF_VAR_db_password env var."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "db_password must be at least 12 characters long."
  }
}

variable "api_keys" {
  description = "Map of API key names to their values."
  type        = map(string)
  sensitive   = true
  default     = {}
}
