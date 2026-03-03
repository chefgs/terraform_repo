resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}

resource "aws_default_security_group" "main_default" {
  vpc_id = aws_vpc.main.id
}
