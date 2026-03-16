##############################################################################
# Variables – 2-Tier AWS Application Infrastructure
##############################################################################

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "2tier-app"
}

variable "environment" {
  description = "Deployment environment (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

# ── Network ───────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ── AMIs (output from Packer builds) ─────────────────────────────────────

variable "web_ami_id" {
  description = "AMI ID for the web tier (built by Packer)"
  type        = string
}

variable "app_ami_id" {
  description = "AMI ID for the app tier (built by Packer)"
  type        = string
}

# ── EC2 / ASG ─────────────────────────────────────────────────────────────

variable "web_instance_type" {
  description = "EC2 instance type for web tier"
  type        = string
  default     = "t3.small"
}

variable "app_instance_type" {
  description = "EC2 instance type for app tier"
  type        = string
  default     = "t3.small"
}

variable "web_min_size" {
  description = "Minimum number of web tier instances"
  type        = number
  default     = 2
}

variable "web_max_size" {
  description = "Maximum number of web tier instances"
  type        = number
  default     = 6
}

variable "web_desired_capacity" {
  description = "Desired number of web tier instances"
  type        = number
  default     = 2
}

variable "app_min_size" {
  description = "Minimum number of app tier instances"
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "Maximum number of app tier instances"
  type        = number
  default     = 6
}

variable "app_desired_capacity" {
  description = "Desired number of app tier instances"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "EC2 key pair name for SSH access (optional)"
  type        = string
  default     = ""
}

# ── RDS ───────────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for RDS PostgreSQL"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = true
}
