variable "region" {
default = "us-west-2"
}
variable "instance_type" {
default = "t2.micro"
}
variable "profile_name" {
default = "default"
}
variable "instance_key" {
default = "saravanan-ec2-key"
}
variable "vpc_cidr" {
default = "178.0.0.0/16"
}
variable "public_subnet_cidr" {
default = "178.0.10.0/24"
}
variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict to a known IP range."
  type        = string
  default     = "10.0.0.0/8"
}