terraform {
  required_providers {
    hashicups = {
      source = "hashicorp.com/edu/hashicups-pf"
    }
  }
}

variable "hashicups_username" {
  description = "HashiCups username for authentication."
  type        = string
  default     = "education"
}

variable "hashicups_password" {
  description = "HashiCups password for authentication."
  type        = string
  sensitive   = true
}

variable "hashicups_host" {
  description = "HashiCups API host URL."
  type        = string
  default     = "https://localhost:19090"
}

provider "hashicups" {
  host     = var.hashicups_host
  username = var.hashicups_username
  password = var.hashicups_password
}

data "hashicups_coffees" "edu" {}

output "edu_coffees" {
  value = data.hashicups_coffees.edu
}
