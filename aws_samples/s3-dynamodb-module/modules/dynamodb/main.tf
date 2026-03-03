resource "random_id" "dynamodb_id" {
  byte_length = 8
}
resource "aws_dynamodb_table" "terraform_state_lock_table" {
  name         = "dynamodb-${var.environment}-${random_id.dynamodb_id.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = {
    Name        = "terraform-state-lock-table"
    Environment = var.environment
  }
}
