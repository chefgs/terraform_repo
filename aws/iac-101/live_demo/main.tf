terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-west-2"
  profile = "default"
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2-live-demo-instance-role"
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
  name = "ec2-live-demo-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "sample_ec2" {
  ami                  = "ami-0d70546e43a941d70"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "Example-Ec2-Instance"
  }
}
