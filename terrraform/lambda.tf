# Archive Lambda function code
data "archive_file" "create_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/create"
  output_path = "${path.module}/lambda-functions/create.zip"
}

data "archive_file" "read_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/read"
  output_path = "${path.module}/lambda-functions/read.zip"
}

data "archive_file" "update_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/update"
  output_path = "${path.module}/lambda-functions/update.zip"
}

data "archive_file" "delete_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/delete"
  output_path = "${path.module}/lambda-functions/delete.zip"
}

# Create Lambda Function
resource "aws_lambda_function" "create_lambda" {
  filename         = data.archive_file.create_lambda_zip.output_path
  function_name    = "${var.project_name}-create"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.create_lambda_zip.output_base64sha256
  runtime         = "python3.12"
  timeout         = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  
  # Best Practice: Enable X-Ray tracing
  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  # Best Practice: Enable dead letter queue
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.crud_table.name
      LOG_LEVEL     = var.log_level
      POWERTOOLS_SERVICE_NAME = "${var.project_name}-create"
      POWERTOOLS_METRICS_NAMESPACE = var.project_name
    }
  }

  tags = {
    Name        = "${var.project_name}-create-lambda"
    Environment = var.environment
    Service     = "crud-api"
  }

  depends_on = [aws_cloudwatch_log_group.create_lambda_logs]
}

# Read Lambda Function
resource "aws_lambda_function" "read_lambda" {
  filename         = data.archive_file.read_lambda_zip.output_path
  function_name    = "${var.project_name}-read"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.read_lambda_zip.output_base64sha256
  runtime         = "python3.12"
  timeout         = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.crud_table.name
      LOG_LEVEL     = var.log_level
      POWERTOOLS_SERVICE_NAME = "${var.project_name}-read"
      POWERTOOLS_METRICS_NAMESPACE = var.project_name
    }
  }

  tags = {
    Name        = "${var.project_name}-read-lambda"
    Environment = var.environment
    Service     = "crud-api"
  }

  depends_on = [aws_cloudwatch_log_group.read_lambda_logs]
}

# Update Lambda Function
resource "aws_lambda_function" "update_lambda" {
  filename         = data.archive_file.update_lambda_zip.output_path
  function_name    = "${var.project_name}-update"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.update_lambda_zip.output_base64sha256
  runtime         = "python3.12"
  timeout         = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.crud_table.name
      LOG_LEVEL     = var.log_level
      POWERTOOLS_SERVICE_NAME = "${var.project_name}-update"
      POWERTOOLS_METRICS_NAMESPACE = var.project_name
    }
  }

  tags = {
    Name        = "${var.project_name}-update-lambda"
    Environment = var.environment
    Service     = "crud-api"
  }

  depends_on = [aws_cloudwatch_log_group.update_lambda_logs]
}

# Delete Lambda Function
resource "aws_lambda_function" "delete_lambda" {
  filename         = data.archive_file.delete_lambda_zip.output_path
  function_name    = "${var.project_name}-delete"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.delete_lambda_zip.output_base64sha256
  runtime         = "python3.12"
  timeout         = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.crud_table.name
      LOG_LEVEL     = var.log_level
      POWERTOOLS_SERVICE_NAME = "${var.project_name}-delete"
      POWERTOOLS_METRICS_NAMESPACE = var.project_name
    }
  }

  tags = {
    Name        = "${var.project_name}-delete-lambda"
    Environment = var.environment
    Service     = "crud-api"
  }

  depends_on = [aws_cloudwatch_log_group.delete_lambda_logs]
}

# CloudWatch Log Groups for Lambda functions (Best Practice: Create before Lambda)
resource "aws_cloudwatch_log_group" "create_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-create"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = {
    Name        = "${var.project_name}-create-logs"
    Environment = var.environment
    Service     = "crud-api"
  }
}

resource "aws_cloudwatch_log_group" "read_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-read"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = {
    Name        = "${var.project_name}-read-logs"
    Environment = var.environment
    Service     = "crud-api"
  }
}

resource "aws_cloudwatch_log_group" "update_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-update"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = {
    Name        = "${var.project_name}-update-logs"
    Environment = var.environment
    Service     = "crud-api"
  }
}

resource "aws_cloudwatch_log_group" "delete_lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-delete"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = {
    Name        = "${var.project_name}-delete-logs"
    Environment = var.environment
    Service     = "crud-api"
  }
}
