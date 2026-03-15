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

resource "aws_iam_role" "ec2_role" {
  name = "ec2-tf-modules-sample-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-tf-modules-sample-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "app_server" {
  ami                  = "ami-830c94e3"
  instance_type        = "t2.micro"
  count                = var.instance_count_needed ? var.instance_count : 1
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

