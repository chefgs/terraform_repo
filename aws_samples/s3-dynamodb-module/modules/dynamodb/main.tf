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

  tags = {
    Name        = "terraform-state-lock-table"
    Environment = var.environment
  }
}
