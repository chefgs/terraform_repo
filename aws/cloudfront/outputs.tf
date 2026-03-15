output "cdn_s3_domain_name" {
  value = aws_s3_bucket.tf_sample_s3.bucket_regional_domain_name
}

output "cdn_r53_hosted_zone_id" {
  value = aws_route53_zone.tf_sample_r53.id
}

output "cdn_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
