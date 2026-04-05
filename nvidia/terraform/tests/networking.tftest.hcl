##############################################################################
# networking.tftest.hcl
#
# Unit tests for the NVIDIA RAG networking resources (VPC, subnet, IGW,
# route table).  Uses mock_provider (Terraform 1.7+) so no AWS credentials
# or real cloud account are required.
#
# Run with:
#   cd nvidia/terraform
#   terraform init
#   terraform test                        # all test files
#   terraform test -filter=tests/networking.tftest.hcl
##############################################################################

mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id           = "ami-0abcdef1234567890"
      name         = "Deep Learning Base OSS Nvidia Driver GPU AMI (Amazon Linux 2) 20240315"
      architecture = "x86_64"
      state        = "available"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_vpc" {
    defaults = {
      id  = "vpc-0mock12345678abcde"
      arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0mock12345678abcde"
    }
  }

  mock_resource "aws_internet_gateway" {
    defaults = {
      id = "igw-0mock12345678abcde"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id                = "subnet-0mock12345678abcde"
      availability_zone = "us-east-1a"
    }
  }

  mock_resource "aws_route_table" {
    defaults = {
      id = "rtb-0mock12345678abcde"
    }
  }

  mock_resource "aws_route_table_association" {
    defaults = {
      id = "rta-0mock12345678abcde"
    }
  }

  mock_resource "aws_security_group" {
    defaults = {
      id  = "sg-0mock12345678abcde"
      arn = "arn:aws:ec2:us-east-1:123456789012:security-group/sg-0mock12345678abcde"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      id  = "nvidia-rag-instance-role"
      arn = "arn:aws:iam::123456789012:role/nvidia-rag-instance-role"
    }
  }

  mock_resource "aws_iam_role_policy" {
    defaults = {
      id = "nvidia-rag-instance-role:nvidia-rag-s3-access"
    }
  }

  mock_resource "aws_iam_instance_profile" {
    defaults = {
      id  = "nvidia-rag-instance-profile"
      arn = "arn:aws:iam::123456789012:instance-profile/nvidia-rag-instance-profile"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      id     = "nvidia-rag-app-mock1234"
      bucket = "nvidia-rag-app-mock1234"
      arn    = "arn:aws:s3:::nvidia-rag-app-mock1234"
    }
  }

  mock_resource "aws_s3_bucket_versioning" {
    defaults = {
      id = "nvidia-rag-app-mock1234"
    }
  }

  mock_resource "aws_s3_bucket_server_side_encryption_configuration" {
    defaults = {
      id = "nvidia-rag-app-mock1234"
    }
  }

  mock_resource "aws_s3_bucket_public_access_block" {
    defaults = {
      id = "nvidia-rag-app-mock1234"
    }
  }

  mock_resource "aws_instance" {
    defaults = {
      id         = "i-0mock12345678abcdef"
      public_ip  = "54.123.45.67"
      public_dns = "ec2-54-123-45-67.compute-1.amazonaws.com"
    }
  }
}

mock_provider "random" {
  mock_resource "random_id" {
    defaults = {
      hex     = "mock1234"
      b64_url = "bW9jazEyMzQ="
      b64_std = "bW9jazEyMzQ="
      dec     = "1836082740"
      id      = "bW9jazEyMzQ="
    }
  }
}

# ── Test: VPC CIDR and DNS defaults ──────────────────────────────────────────
run "vpc_cidr_and_dns" {
  command = plan

  assert {
    condition     = aws_vpc.rag_vpc.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block should default to 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.rag_vpc.enable_dns_support == true
    error_message = "DNS support must be enabled on the VPC"
  }

  assert {
    condition     = aws_vpc.rag_vpc.enable_dns_hostnames == true
    error_message = "DNS hostnames must be enabled on the VPC"
  }
}

# ── Test: VPC tags ────────────────────────────────────────────────────────────
run "vpc_name_tag" {
  command = plan

  assert {
    condition     = aws_vpc.rag_vpc.tags["Name"] == "nvidia-rag-vpc"
    error_message = "VPC Name tag should be 'nvidia-rag-vpc'"
  }
}

# ── Test: Public subnet configuration ────────────────────────────────────────
run "public_subnet_config" {
  command = plan

  assert {
    condition     = aws_subnet.public.cidr_block == "10.0.1.0/24"
    error_message = "Public subnet CIDR should default to 10.0.1.0/24"
  }

  assert {
    condition     = aws_subnet.public.map_public_ip_on_launch == true
    error_message = "Public subnet should auto-assign public IPs"
  }
}

# ── Test: Custom VPC CIDR ────────────────────────────────────────────────────
run "custom_vpc_cidr" {
  command = plan

  variables {
    vpc_cidr           = "172.16.0.0/16"
    public_subnet_cidr = "172.16.1.0/24"
  }

  assert {
    condition     = aws_vpc.rag_vpc.cidr_block == "172.16.0.0/16"
    error_message = "VPC CIDR should reflect the custom value"
  }

  assert {
    condition     = aws_subnet.public.cidr_block == "172.16.1.0/24"
    error_message = "Subnet CIDR should reflect the custom value"
  }
}

# ── Test: Route table has a default internet route ───────────────────────────
run "route_table_default_route" {
  command = plan

  assert {
    condition = anytrue([
      for route in aws_route_table.public.route :
      route.cidr_block == "0.0.0.0/0"
    ])
    error_message = "Route table must have a default 0.0.0.0/0 route to the internet gateway"
  }
}

# ── Test: IGW tag ─────────────────────────────────────────────────────────────
run "igw_name_tag" {
  command = plan

  assert {
    condition     = aws_internet_gateway.igw.tags["Name"] == "nvidia-rag-igw"
    error_message = "Internet gateway Name tag should be 'nvidia-rag-igw'"
  }
}
