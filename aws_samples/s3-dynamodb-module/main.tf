provider "aws" {
  region = var.region
}

module "s3" {
  source          = "./modules/s3"
  environment     = var.environment
}

module "dynamodb" {
  source              = "./modules/dynamodb"
  environment         = var.environment
}
