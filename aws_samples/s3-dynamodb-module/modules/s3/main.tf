resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "tf-backend-${var.environment}-${random_id.bucket_id.hex}"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-state-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_sse" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_bucket_public_access" {
  bucket                  = aws_s3_bucket.terraform_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_bucket_lifecycle" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "terraform_state_bucket_logging" {
  bucket        = aws_s3_bucket.terraform_state_bucket.id
  target_bucket = aws_s3_bucket.terraform_state_bucket.id
  target_prefix = "log/"
}
