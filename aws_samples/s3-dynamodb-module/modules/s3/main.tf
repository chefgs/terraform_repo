resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "tf-backend-${var.environment}-${random_id.bucket_id.hex}"

  # versioning is deprecated

  # server_side_encryption_configuration is deprecated

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-state-bucket"
    Environment = var.environment
  }
}
