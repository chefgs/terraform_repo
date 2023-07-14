# Variables Block
# Common values used across the terraform code can be added as variables
# We can override the values using .tfvars files while running terraform plan/apply
variable "region" {
  default = "us-west-2"
}

# Terraform Required provider Block
# In this section, we need to declare the providers and their version constraint used to create the infrastructure
# It is needed to avoid any version mismatch of the provider 
# Also it is good to mention what is the required version of Terraform CLI needed for the infra creation
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.0.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "gsaravanan-tf"

    workspaces {
      name = "example-workspace"
    }
  }
}

# Provider block declares the provider on which the infra will be created
# For AWS, one way of doing the cred authentication is to install AWS CLI and configure it to add access_key_id and secret_access_key
provider "aws" {
  profile = "default"
  region  = var.region
}

# Resource Block
# In this section, we will add the resources that we will be adding and managing in Cloud infra
# 
resource "aws_instance" "app_server" {
  # x86 AMIs with hvm Ubuntu 22.04 -> ami-03f65b8614a860c29, 20.04 -> ami-0c65adc9a5c1b5d7c. Amz Linux ami-07dfed28fcf95241c
  ami           = "ami-03f65b8614a860c29"
  instance_type = "t2.micro"

  # We can use the provisioners like user_data to run scripts that will be executed when the instance is getting created.
  user_data = "./install_docker.sh > /tmp/install_docker.log"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

# Output Block
# Here we can print the values of Infra resources that is supported
# For ex: We are printing instance_id and instance_state
output "instance_id" {
  description = "ID of the EC2 instance(s)"
  value       = aws_instance.app_server.*.id
}

output "instance_state" {
  description = "State of the EC2 instance(s)"
  value       = aws_instance.app_server.*.instance_state
}
