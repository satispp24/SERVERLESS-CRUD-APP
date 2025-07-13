# API Gateway Deployment
resource "aws_api_gateway_deployment" "crud_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.create_integration,
    aws_api_gateway_integration.read_all_integration,
    aws_api_gateway_integration.read_integration,
    aws_api_gateway_integration.update_integration,
    aws_api_gateway_integration.delete_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.crud_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "crud_api_stage" {
  deployment_id = aws_api_gateway_deployment.crud_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.crud_api.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-api-stage"
    Environment = var.environment
  }
}
