variable "region" {
default = "us-west-2"
}
variable "instance_type" {}
variable "creds" {}
variable "instance_key" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict to a known IP range."
  type        = string
  default     = "10.0.0.0/8"
}
variable "ssh_allowed_ipv6_cidr" {
  description = "IPv6 CIDR block allowed to SSH into the instance. Restrict to a known IP range."
  type        = string
  default     = "fc00::/7"
}