module "ec2_instances" {
  source  = "./modules/create_ec2"

  region = "us-west-2"
}