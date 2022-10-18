variable "do_token" {
  type = string
}

variable "env" {
  type = string
  default = "stage"
}

variable "region" {
  type = string
  default = "blr1"
}

variable "name" {
  type = string
  default = "terraform"
}

variable "image" {
  type = string
  default = "ubuntu-18-04-x64"
}

variable "size" {
  type = string
  default = "s-1vcpu-1gb"
}
