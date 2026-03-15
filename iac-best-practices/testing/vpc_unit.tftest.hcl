##############################################################################
# VPC Module Unit Tests
# Uses mock_provider (Terraform 1.7+) to avoid creating real resources
##############################################################################

mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id         = "vpc-mock12345678"
      arn        = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-mock12345678"
      cidr_block = "10.0.0.0/16"
    }
  }

  mock_resource "aws_internet_gateway" {
    defaults = {
      id = "igw-mock12345678"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id                = "subnet-mock12345678"
      availability_zone = "us-east-1a"
    }
  }

  mock_resource "aws_route_table" {
    defaults = {
      id = "rtb-mock12345678"
    }
  }

  mock_resource "aws_route_table_association" {
    defaults = {
      id = "rta-mock12345678"
    }
  }

  mock_resource "aws_eip" {
    defaults = {
      id = "eipalloc-mock12345678"
    }
  }

  mock_resource "aws_nat_gateway" {
    defaults = {
      id = "nat-mock12345678"
    }
  }
}

# ── Test: Basic VPC creation ───────────────────────────────────────────────
run "vpc_basic_creation" {
  command = plan

  variables {
    name               = "test-vpc"
    cidr_block         = "10.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    enable_nat_gateway  = false
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "DNS support should be enabled on VPC"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled on VPC"
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Should create 2 public subnets"
  }
}

# ── Test: VPC without NAT gateway ──────────────────────────────────────────
run "vpc_no_nat_gateway" {
  command = plan

  variables {
    name               = "test-vpc"
    cidr_block         = "10.0.0.0/16"
    availability_zones = ["us-east-1a"]
    public_subnet_cidrs = ["10.0.1.0/24"]
    enable_nat_gateway  = false
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "NAT gateway should not be created when enable_nat_gateway = false"
  }
}

# ── Test: VPC with NAT gateway ──────────────────────────────────────────────
run "vpc_with_nat_gateway" {
  command = plan

  variables {
    name               = "test-vpc"
    cidr_block         = "10.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
    enable_nat_gateway   = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "Exactly one NAT gateway should be created"
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }
}

# ── Test: Tag propagation ─────────────────────────────────────────────────
run "vpc_tag_propagation" {
  command = plan

  variables {
    name               = "tagged-vpc"
    cidr_block         = "192.168.0.0/16"
    availability_zones = ["us-east-1a"]
    public_subnet_cidrs = ["192.168.1.0/24"]
    tags = {
      Project     = "test-project"
      Environment = "test"
    }
  }

  assert {
    condition     = aws_vpc.this.tags["Name"] == "tagged-vpc"
    error_message = "VPC Name tag should be set from the name variable"
  }

  assert {
    condition     = aws_vpc.this.tags["Project"] == "test-project"
    error_message = "VPC Project tag should be propagated"
  }
}
