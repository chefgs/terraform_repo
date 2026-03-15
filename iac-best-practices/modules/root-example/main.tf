##############################################################################
# Root Module – Wires together VPC, Security Group modules
# Demonstrates IaC best practices:
#   - Module composition
#   - Local values for DRY (Don't Repeat Yourself)
#   - Data sources for AZ discovery
#   - Consistent tagging strategy
##############################################################################

# ── Local values (derived / computed) ─────────────────────────────────────
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.team_name
  }

  name_prefix = "${var.project_name}-${var.environment}"

  # Slice AZ list to match number of subnets needed
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# ── Data Sources ──────────────────────────────────────────────────────────
data "aws_availability_zones" "available" {
  state = "available"
}

# ── VPC Module ────────────────────────────────────────────────────────────
module "vpc" {
  source = "../vpc"

  name       = "${local.name_prefix}-vpc"
  cidr_block = var.vpc_cidr

  availability_zones   = local.azs
  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]

  enable_nat_gateway = var.environment == "prod"

  tags = local.common_tags
}

# ── Web Tier Security Group ────────────────────────────────────────────────
module "web_sg" {
  source = "../security-group"

  name   = "${local.name_prefix}-web-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from internet"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from internet"
    },
  ]

  tags = local.common_tags
}

# ── App Tier Security Group ────────────────────────────────────────────────
module "app_sg" {
  source = "../security-group"

  name   = "${local.name_prefix}-app-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      security_groups = [module.web_sg.security_group_id]
      description     = "Allow traffic from web tier only"
    },
  ]

  tags = local.common_tags
}
