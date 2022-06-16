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
  region = "us-west-2"
  profile = "default"
}


resource "aws_instance" "sample_ec2" {
  ami           = "ami-005e54dee72cc1d00"
  instance_type = "t2.micro"
  # key_name = var.instance_key
  # security_groups = [aws_security_group.sample_sg.name]
  # count = 1

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "Example-Ec2-Instance"
    Session = "KCD-Chennai"
  }
}
