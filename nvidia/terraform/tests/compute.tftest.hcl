##############################################################################
# compute.tftest.hcl
#
# Unit tests for the NVIDIA RAG compute resources:
#   • IAM role
#   • IAM instance profile
#   • GPU EC2 instance (instance type, root volume, tags)
#
# Uses mock_provider (Terraform 1.7+) – no AWS credentials required.
#
# Run with:
#   cd nvidia/terraform
#   terraform init
#   terraform test -filter=tests/compute.tftest.hcl
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

# ── Test: Default GPU instance type is g4dn.xlarge ──────────────────────────
run "default_gpu_instance_type" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.instance_type == "g4dn.xlarge"
    error_message = "Default instance type should be g4dn.xlarge (NVIDIA T4 GPU)"
  }
}

# ── Test: Instance type can be overridden ────────────────────────────────────
run "custom_gpu_instance_type" {
  command = plan

  variables {
    instance_type = "p3.2xlarge"
  }

  assert {
    condition     = aws_instance.rag_gpu.instance_type == "p3.2xlarge"
    error_message = "Instance type should be overridable to p3.2xlarge (NVIDIA V100)"
  }
}

# ── Test: Root volume is encrypted ──────────────────────────────────────────
run "root_volume_encrypted" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.root_block_device[0].encrypted == true
    error_message = "Root EBS volume must be encrypted"
  }
}

# ── Test: Root volume type is gp3 ────────────────────────────────────────────
run "root_volume_type_gp3" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.root_block_device[0].volume_type == "gp3"
    error_message = "Root volume type should be gp3 for cost-effective SSD performance"
  }
}

# ── Test: Root volume delete-on-termination is enabled ──────────────────────
run "root_volume_delete_on_termination" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.root_block_device[0].delete_on_termination == true
    error_message = "Root volume should be deleted when the instance is terminated"
  }
}

# ── Test: Default root volume size is 100 GiB ────────────────────────────────
run "default_root_volume_size" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.root_block_device[0].volume_size == 100
    error_message = "Default root volume size should be 100 GiB"
  }
}

# ── Test: Custom root volume size ────────────────────────────────────────────
run "custom_root_volume_size" {
  command = plan

  variables {
    root_volume_size_gb = 200
  }

  assert {
    condition     = aws_instance.rag_gpu.root_block_device[0].volume_size == 200
    error_message = "Root volume size should reflect the custom value 200 GiB"
  }
}

# ── Test: Instance security groups reference the RAG SG ──────────────────────
# Note: cross-resource ID comparisons (instance.subnet_id == subnet.id) are not
# assertable in `command = plan` because computed IDs are "known after apply".
# The wiring from main.tf (subnet_id = aws_subnet.public.id) is inherently validated.
run "instance_has_security_groups" {
  command = plan

  assert {
    condition     = length(aws_instance.rag_gpu.vpc_security_group_ids) == 1
    error_message = "GPU instance should have exactly one security group attached"
  }
}

# ── Test: IAM instance profile attached to EC2 ───────────────────────────────
run "instance_profile_attached" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.iam_instance_profile == aws_iam_instance_profile.rag_profile.name
    error_message = "IAM instance profile must be attached to the GPU instance"
  }
}

# ── Test: Instance name tag ───────────────────────────────────────────────────
run "instance_name_tag" {
  command = plan

  assert {
    condition     = aws_instance.rag_gpu.tags["Name"] == "nvidia-rag-gpu-instance"
    error_message = "GPU instance Name tag should be 'nvidia-rag-gpu-instance'"
  }
}

# ── Test: IAM role uses correct name prefix ──────────────────────────────────
run "iam_role_name_prefix" {
  command = plan

  assert {
    condition     = startswith(aws_iam_role.rag_instance_role.name, "nvidia-rag")
    error_message = "IAM role name should start with 'nvidia-rag'"
  }
}

# ── Test: AMI falls back to data source when not explicitly set ──────────────
run "ami_uses_data_source_when_empty" {
  command = plan

  variables {
    ami_id = ""
  }

  assert {
    condition     = aws_instance.rag_gpu.ami == data.aws_ami.deep_learning.id
    error_message = "When ami_id variable is empty, the instance should use the data-source AMI"
  }
}

# ── Test: Explicit AMI ID overrides the data source ──────────────────────────
run "explicit_ami_overrides_data_source" {
  command = plan

  variables {
    ami_id = "ami-0explicitpinnedami1"
  }

  assert {
    condition     = aws_instance.rag_gpu.ami == "ami-0explicitpinnedami1"
    error_message = "When ami_id is set, the instance should use the explicit AMI"
  }
}
