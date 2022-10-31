resource "random_string" "random_s3_staticbucket_val" {
  length           = 4
  special          = true
  override_special = ".-"
  upper            = false
}

locals {
  static_bucket_name = "static-hosting-bucket-${random_string.random_s3_staticbucket_val.result}"
}

resource "aws_s3_bucket" "s3_static_hosting" {
  bucket = local.static_bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}