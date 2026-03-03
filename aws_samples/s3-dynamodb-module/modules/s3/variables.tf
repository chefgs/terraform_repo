variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "log_bucket_id" {
  description = "S3 bucket ID for access logging. If empty, logs to itself."
  type        = string
  default     = ""
}
