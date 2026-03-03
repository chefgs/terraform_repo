variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the instance"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}