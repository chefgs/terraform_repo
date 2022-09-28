# Elastic search domain name
variable "domain" {
  default = "gs-demo-es"
}

# AWS access key
variable "access_key" {
default = "A************Q"
}

# AWS secret key
variable "secret" {
default = "u************s"
}

# AWS account id
variable "aws_account_id" {
default = "123456789876"
}

# Region of the ES
variable "region" {
default = "us-west-2"
}

# AWS account config
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret}"
  region     = "${var.region}"
}

# Terraform AWS ES Resource definition section
resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.domain}"
  elasticsearch_version = "6.2"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
	instance_count = "1"
  }

  ebs_options {
    ebs_enabled = "true"
    volume_size = "10"
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:us-west-2:${var.aws_account_id}:domain/${var.domain}/*"
    }
  ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Domain = "TestDomain"
  }
}
