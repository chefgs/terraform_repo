resource "random_string" "random_s3_staticbucket_val" {
  length           = 4
  special          = true
  override_special = ".-"
  upper            = false
}

locals {
  static_bucket_name = "static-hosting-bucket-${random_string.random_s3_staticbucket_val.result}"
}

resource "aws_s3_bucket" "s3_static_hosting" {
  bucket = local.static_bucket_name
  force_destroy = true

  tags = {
    Name    = "Website bucket"
    Purpose = "AWS CDN Static Hosting Bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3_static_hosting_versioning" {
  bucket = aws_s3_bucket.s3_static_hosting.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_static_hosting_sse" {
  bucket = aws_s3_bucket.s3_static_hosting.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_static_hosting_public_access" {
  bucket                  = aws_s3_bucket.s3_static_hosting.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "s3_static_hosting_logging" {
  bucket        = aws_s3_bucket.s3_static_hosting.id
  target_bucket = aws_s3_bucket.tf_sample_log_s3.id
  target_prefix = "static-log/"
}

resource "aws_s3_bucket_website_configuration" "s3_static_hosting_website" {
  bucket = aws_s3_bucket.s3_static_hosting.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}