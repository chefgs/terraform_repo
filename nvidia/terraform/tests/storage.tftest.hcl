##############################################################################
# storage.tftest.hcl
#
# Unit tests for the NVIDIA RAG S3 storage resources:
#   • Bucket encryption (AES256 server-side encryption)
#   • Versioning enabled
#   • Public access fully blocked
#   • Bucket name auto-generation and explicit override
#
# Uses mock_provider (Terraform 1.7+) – no AWS credentials required.
#
# Run with:
#   cd nvidia/terraform
#   terraform init
#   terraform test -filter=tests/storage.tftest.hcl
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

# ── Test: S3 bucket name is auto-generated when variable is empty ────────────
run "bucket_name_auto_generated" {
  command = plan

  variables {
    rag_app_s3_bucket = ""
  }

  assert {
    condition     = startswith(aws_s3_bucket.rag_docs.bucket, "nvidia-rag-app-")
    error_message = "Bucket name should be auto-generated with prefix 'nvidia-rag-app-'"
  }
}

# ── Test: Explicit bucket name is used when provided ─────────────────────────
run "explicit_bucket_name" {
  command = plan

  variables {
    rag_app_s3_bucket = "my-custom-rag-bucket-20240315"
  }

  assert {
    condition     = aws_s3_bucket.rag_docs.bucket == "my-custom-rag-bucket-20240315"
    error_message = "Explicit bucket name variable should be used as the bucket name"
  }
}

# ── Test: S3 versioning is enabled ───────────────────────────────────────────
run "s3_versioning_enabled" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.rag_docs.versioning_configuration[0].status == "Enabled"
    error_message = "S3 bucket versioning must be enabled for document safety"
  }
}

# ── Test: Server-side encryption uses AES256 ─────────────────────────────────
run "s3_sse_aes256" {
  command = plan

  assert {
    condition = anytrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.rag_docs.rule :
      anytrue([
        for enc in r.apply_server_side_encryption_by_default :
        enc.sse_algorithm == "AES256"
      ])
    ])
    error_message = "S3 bucket must use AES256 server-side encryption"
  }
}

# ── Test: Public ACLs are blocked ────────────────────────────────────────────
run "s3_block_public_acls" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.rag_docs.block_public_acls == true
    error_message = "Public ACLs must be blocked on the documents bucket"
  }
}

# ── Test: Public bucket policies are blocked ─────────────────────────────────
run "s3_block_public_policy" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.rag_docs.block_public_policy == true
    error_message = "Public bucket policies must be blocked on the documents bucket"
  }
}

# ── Test: Existing public ACLs are ignored ───────────────────────────────────
run "s3_ignore_public_acls" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.rag_docs.ignore_public_acls == true
    error_message = "Existing public ACLs must be ignored on the documents bucket"
  }
}

# ── Test: Public bucket access is fully restricted ───────────────────────────
run "s3_restrict_public_buckets" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.rag_docs.restrict_public_buckets == true
    error_message = "Public bucket access must be fully restricted on the documents bucket"
  }
}

# ── Test: Bucket name tag is set ─────────────────────────────────────────────
run "s3_bucket_name_tag" {
  command = plan

  assert {
    condition     = aws_s3_bucket.rag_docs.tags["Name"] != null
    error_message = "S3 bucket should have a Name tag"
  }
}
