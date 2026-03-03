resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu_linux.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]
  key_name = var.key_name
  user_data = var.user_data
  monitoring    = true
  ebs_optimized = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "MyEC2Instance"
  }
}
