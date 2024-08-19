provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source    = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "subnet" {
  source                = "./modules/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "us-west-2a"
}

module "security_group" {
  source = "./modules/security-group"
  vpc_id = module.vpc.vpc_id
}


data "aws_ami" "example" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

module "ec2" {
  source            = "./modules/ec2"
  ami               = data.aws_ami.example.id
  instance_type     = "t2.micro"
  subnet_id         = module.subnet.subnet_id
  security_group_id = module.security_group.security_group_id
  key_name = var.key_name
  user_data = file("${var.user_data}")
}