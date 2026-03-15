terraform {
  required_providers {
    hashicups = {
      source  = "hashicorp.com/edu/hashicups-pf"
    }
  }
  required_version = ">= 1.1.0"
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
  username = var.hashicups_username
  password = var.hashicups_password
  host     = var.hashicups_host
}

resource "hashicups_order" "edu" {
  items = [{
    coffee = {
      id = 3
    }
    quantity = 2
    }, {
    coffee = {
      id = 1
    }
    quantity = 2
    }
  ]
}

output "edu_order" {
  value = hashicups_order.edu
}
