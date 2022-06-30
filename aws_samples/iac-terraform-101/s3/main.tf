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