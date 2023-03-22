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