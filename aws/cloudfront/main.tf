# Create a VPC
resource "aws_vpc" "tf_sample_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "tf_sample_vpc"
  }
}

# Create route 53
resource "aws_route53_zone" "tf_sample_r53" {
  name = "cdnr53.com"

  vpc {
    vpc_id = aws_vpc.tf_sample_vpc.id
  }
}

locals {
  s3_origin_id = "myS3Origin"
}

locals {
  s3_static_hosting_origin_id = "myStaticS3Origin"
}

resource "aws_cloudfront_origin_access_identity" "cdn_origin_access_identity" {
  comment = "aws_cloudfront_origin_access_identity"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.tf_sample_s3.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn_origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    bucket          = "${aws_s3_bucket.tf_sample_log_s3.bucket}.s3.amazonaws.com"
    include_cookies = false
    prefix          = "myprefix"
  }

  web_acl_id = aws_waf_web_acl.waf_acl.id

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.s3_static_hosting.bucket_regional_domain_name
    origin_id   = local.s3_static_hosting_origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only" # Possible values http-only, https-only, or match-viewer
      origin_ssl_protocols   = ["TLSv1"]

    }
  }

  #This block has been added to verify the custom_origin policy scenario - cache precendence 0
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_static_hosting_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
