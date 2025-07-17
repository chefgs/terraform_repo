variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  default     = "your-s3-bucket-name"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  default     = "your-dynamodb-table-name"
}

variable "environment" {
  description = "Environment tag"
  default     = "dev"
}
