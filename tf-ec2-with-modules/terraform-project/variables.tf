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