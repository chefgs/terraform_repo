resource "aws_instance" "sample_ec2" {
  ami           = "ami-005e54dee72cc1d00"
  instance_type = "t2.micro"
  key_name = var.instance_key

  user_data = <<-EOF
  #!/bin/bash
  echo "This script was executed from user_data"
  EOF

  tags = {
    Name = "ExampleAppServerInstance"
    Session = "KCD-Chennai"
  }
}

