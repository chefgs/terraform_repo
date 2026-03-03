resource "random_string" "random_s3_log_val" {
  length  = 4
  special = false
  #override_special = ".-"
  upper = false
}

locals {
  log_bucket_name = "my-log-bucket-${random_string.random_s3_log_val.result}"
}

resource "aws_s3_bucket" "tf_sample_log_s3" {
  bucket = local.log_bucket_name
  # hosted_zone_id = aws_route53_zone.tf_sample_r53.id
  force_destroy = true

  tags = {
    Name    = "My Log Bucket"
    Purpose = "AWS CDN Sample Bucket"
  }
}

resource "aws_s3_bucket_versioning" "tf_sample_log_s3_versioning" {
  bucket = aws_s3_bucket.tf_sample_log_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_sample_log_s3_sse" {
  bucket = aws_s3_bucket.tf_sample_log_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_sample_log_s3_public_access" {
  bucket                  = aws_s3_bucket.tf_sample_log_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_sample_log_s3_lifecycle" {
  bucket = aws_s3_bucket.tf_sample_log_s3.id
  rule {
    id     = "expire-old-logs"
    status = "Enabled"
    expiration {
      days = 365
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "tf_sample_log_s3_logging" {
  bucket        = aws_s3_bucket.tf_sample_log_s3.id
  target_bucket = aws_s3_bucket.tf_sample_log_s3.id
  target_prefix = "log/"
}