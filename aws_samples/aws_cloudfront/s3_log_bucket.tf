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