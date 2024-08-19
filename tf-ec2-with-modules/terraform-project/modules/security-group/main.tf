resource "aws_security_group" "main" {
  vpc_id = var.vpc_id

  ingress {
    description = "Allow Jenkins traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows access from anywhere
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows access from anywhere
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust for more security if needed
  }

  tags = {
    Name = "allow_ssh"
  }
}
