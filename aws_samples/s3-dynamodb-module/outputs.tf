output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_name
}
