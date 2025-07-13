# KMS Key for CloudWatch Logs encryption (optional)
resource "aws_kms_key" "logs" {
  count                   = var.enable_log_encryption ? 1 : 0
  description             = "KMS key for ${var.project_name} CloudWatch logs encryption"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-logs-kms"
    Environment = var.environment
    Service     = "crud-api"
  }
}

resource "aws_kms_alias" "logs" {
  count         = var.enable_log_encryption ? 1 : 0
  name          = "alias/${var.project_name}-logs"
  target_key_id = aws_kms_key.logs[0].key_id
}

# KMS Key for DynamoDB encryption (optional)
resource "aws_kms_key" "dynamodb" {
  count                   = var.enable_dynamodb_encryption ? 1 : 0
  description             = "KMS key for ${var.project_name} DynamoDB encryption"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow DynamoDB Service"
        Effect = "Allow"
        Principal = {
          Service = "dynamodb.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-dynamodb-kms"
    Environment = var.environment
    Service     = "crud-api"
  }
}

resource "aws_kms_alias" "dynamodb" {
  count         = var.enable_dynamodb_encryption ? 1 : 0
  name          = "alias/${var.project_name}-dynamodb"
  target_key_id = aws_kms_key.dynamodb[0].key_id
}
