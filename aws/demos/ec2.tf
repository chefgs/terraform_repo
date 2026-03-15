terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-demo-instance-role"
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
  name = "ec2-demo-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "app_server" {
  ami                  = "ami-0fcf52bcf5db7b003"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "YoutubeDemoEC2Instance"
  }
}

