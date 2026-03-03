resource "aws_instance" "sample_ec2" {
  ami           = "ami-0d70546e43a941d70"
  instance_type = "t2.micro"
  key_name = var.instance_key
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

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "ExampleAppServerInstance"
    Session = "KCD-Chennai"
  }
}

