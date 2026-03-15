variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict to a known IP range."
  type        = string
  default     = "10.0.0.0/8"
}