variable "region" {
default = "us-west-2"
}

variable "instance_count_needed" {
  default = "true"
}

variable "instance_count" {
  default = 2
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  count = var.instance_count_needed ? var.instance_count : 1

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

