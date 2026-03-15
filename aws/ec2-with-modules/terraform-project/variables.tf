# Define any global variables if needed
variable "key_name" {
  description = "value of the key pair"
  type = string
  default = "your-pem-key-name"
}

variable "user_data" {
  description = "filename of userdata file"
  type = string
  default = "userdata.sh"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict to a known IP range."
  type        = string
  default     = "10.0.0.0/8"
}