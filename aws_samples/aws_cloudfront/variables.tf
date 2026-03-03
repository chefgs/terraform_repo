variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "188.0.0.0/16"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront HTTPS distribution"
  type        = string
  default     = ""
}