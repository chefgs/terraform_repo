##############################################################################
# security.tftest.hcl
#
# Unit tests for the NVIDIA RAG security group configuration.
# Uses mock_provider (Terraform 1.7+) – no AWS credentials required.
#
# Run with:
#   cd nvidia/terraform
#   terraform init
#   terraform test -filter=tests/security.tftest.hcl
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

# ── Test: Security group has both expected ingress rules ─────────────────────
run "sg_has_ssh_and_app_ingress" {
  command = plan

  assert {
    condition = anytrue([
      for rule in aws_security_group.rag_sg.ingress :
      rule.from_port == 22 && rule.to_port == 22 && rule.protocol == "tcp"
    ])
    error_message = "Security group must allow TCP port 22 (SSH)"
  }

  assert {
    condition = anytrue([
      for rule in aws_security_group.rag_sg.ingress :
      rule.from_port == 8080 && rule.to_port == 8080 && rule.protocol == "tcp"
    ])
    error_message = "Security group must allow TCP port 8080 (RAG app API)"
  }
}

# ── Test: Default egress allows all outbound traffic ─────────────────────────
run "sg_egress_allows_all" {
  command = plan

  assert {
    condition = anytrue([
      for rule in aws_security_group.rag_sg.egress :
      rule.from_port == 0 && rule.to_port == 0 && rule.protocol == "-1" &&
      contains(rule.cidr_blocks, "0.0.0.0/0")
    ])
    error_message = "Security group must have an allow-all egress rule"
  }
}

# ── Test: Security group description is set ──────────────────────────────────
# Note: cross-resource ID comparisons (sg.vpc_id == vpc.id) are not assertable
# in `command = plan` mode because computed IDs are "known after apply".
# The wiring is guaranteed by the Terraform reference in main.tf.
run "sg_has_description" {
  command = plan

  assert {
    condition     = aws_security_group.rag_sg.description != ""
    error_message = "Security group must have a non-empty description"
  }
}

# ── Test: Custom app port is used in security group ──────────────────────────
run "sg_custom_app_port" {
  command = plan

  variables {
    app_port = 9090
  }

  assert {
    condition = anytrue([
      for rule in aws_security_group.rag_sg.ingress :
      rule.from_port == 9090 && rule.to_port == 9090 && rule.protocol == "tcp"
    ])
    error_message = "Security group must allow the custom app port 9090"
  }
}

# ── Test: SSH CIDR can be restricted ─────────────────────────────────────────
run "sg_restricted_ssh_cidr" {
  command = plan

  variables {
    ssh_allowed_cidr = "203.0.113.0/24"
  }

  assert {
    condition = anytrue([
      for rule in aws_security_group.rag_sg.ingress :
      rule.from_port == 22 && contains(rule.cidr_blocks, "203.0.113.0/24")
    ])
    error_message = "SSH ingress rule should use the restricted CIDR 203.0.113.0/24"
  }
}

# ── Test: Security group name tag ────────────────────────────────────────────
run "sg_name_tag" {
  command = plan

  assert {
    condition     = aws_security_group.rag_sg.tags["Name"] == "nvidia-rag-sg"
    error_message = "Security group Name tag should be 'nvidia-rag-sg'"
  }
}
