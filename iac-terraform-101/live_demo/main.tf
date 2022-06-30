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


resource "aws_instance" "sample_ec2" {
  ami           = "ami-0d70546e43a941d70"
  instance_type = "t2.micro"

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "Example-Ec2-Instance"
  }
}
