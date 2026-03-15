resource "aws_iam_role" "ec2_role" {
  name = "ec2-iac101-create-instance-role"
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
  name = "ec2-iac101-create-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "sample_ec2" {
  ami                  = "ami-0d70546e43a941d70"
  instance_type        = "t2.micro"
  key_name             = var.instance_key
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
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
