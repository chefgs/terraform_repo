resource "random_string" "random_val" {
  length           = 5
  special          = true
  override_special = ".-"
  upper            = false
}

locals {
  bucket_name = "sample-s3-${random_string.random_val.result}"
}

resource "aws_s3_bucket" "sample_s3" {
  bucket = local.bucket_name

  tags = {
    Name    = "My Sample Bucket"
    Session = "KCD-Chennai"
  }
}

resource "aws_s3_bucket_acl" "sample_s3_acl" {
  bucket = aws_s3_bucket.sample_s3.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "sample_s3_versioning" {
  bucket = aws_s3_bucket.sample_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sample_s3_sse" {
  bucket = aws_s3_bucket.sample_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sample_s3_public_access" {
  bucket                  = aws_s3_bucket.sample_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "sample_s3_logging" {
  bucket        = aws_s3_bucket.sample_s3.id
  target_bucket = aws_s3_bucket.sample_s3.id
  target_prefix = "log/"
}