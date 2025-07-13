# DynamoDB Table
resource "aws_dynamodb_table" "crud_table" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Best Practice: Enable point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_dynamodb_pitr
  }

  # Best Practice: Enable server-side encryption
  server_side_encryption {
    enabled = var.enable_dynamodb_encryption
  }

  # Best Practice: Enable deletion protection for production
  deletion_protection_enabled = var.enable_deletion_protection

  tags = {
    Name        = var.table_name
    Environment = var.environment
    Service     = "crud-api"
    Backup      = var.enable_dynamodb_pitr ? "enabled" : "disabled"
  }
}
