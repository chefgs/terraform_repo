variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "kms_key_arn" {
  description = "KMS Key ARN for DynamoDB encryption"
  type        = string
  default     = ""
}
