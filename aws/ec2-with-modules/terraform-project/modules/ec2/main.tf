resource "aws_iam_role" "ec2_role" {
  name = "ec2-with-modules-instance-role"
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
  name = "ec2-with-modules-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "main" {
  ami                  = data.aws_ami.ubuntu_linux.id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  security_groups      = [var.security_group_id]
  key_name             = var.key_name
  user_data            = var.user_data
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "MyEC2Instance"
  }
}
