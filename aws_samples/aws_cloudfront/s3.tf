resource "random_string" "random_val" {
  length  = 4
  special = false
  #override_special = ".-"
  upper = false
}

locals {
  bucket_name = "my-test-bucket-${random_string.random_val.result}"
}

resource "aws_s3_bucket" "tf_sample_s3" {
  bucket         = local.bucket_name
  hosted_zone_id = aws_route53_zone.tf_sample_r53.id
  force_destroy = true

  tags = {
    Name    = "My bucket"
    Purpose = "AWS CDN Sample Bucket"
  }
}