# Output values
output "api_gateway_url" {
  description = "Base URL for API Gateway stage"
  value       = aws_api_gateway_stage.crud_api_stage.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.crud_api.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.crud_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.crud_table.arn
}

output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value = {
    create = aws_lambda_function.create_lambda.function_name
    read   = aws_lambda_function.read_lambda.function_name
    update = aws_lambda_function.update_lambda.function_name
    delete = aws_lambda_function.delete_lambda.function_name
  }
}

output "api_endpoints" {
  description = "API endpoints for CRUD operations"
  value = {
    create_item    = "${aws_api_gateway_stage.crud_api_stage.invoke_url}/items"
    read_all_items = "${aws_api_gateway_stage.crud_api_stage.invoke_url}/items"
    read_item      = "${aws_api_gateway_stage.crud_api_stage.invoke_url}/items/{id}"
    update_item    = "${aws_api_gateway_stage.crud_api_stage.invoke_url}/items/{id}"
    delete_item    = "${aws_api_gateway_stage.crud_api_stage.invoke_url}/items/{id}"
  }
}

output "curl_examples" {
  description = "Example curl commands for testing the API"
  value = {
    create = "curl -X POST ${aws_api_gateway_stage.crud_api_stage.invoke_url}/items -H 'Content-Type: application/json' -d '{\"name\":\"Test Item\",\"description\":\"This is a test item\"}'"
    read_all = "curl -X GET '${aws_api_gateway_stage.crud_api_stage.invoke_url}/items'"
    read_one = "curl -X GET '${aws_api_gateway_stage.crud_api_stage.invoke_url}/items/ITEM_ID'"
    update = "curl -X PUT ${aws_api_gateway_stage.crud_api_stage.invoke_url}/items/ITEM_ID -H 'Content-Type: application/json' -d '{\"name\":\"Updated Item\",\"description\":\"Updated description\"}'"
    delete = "curl -X DELETE '${aws_api_gateway_stage.crud_api_stage.invoke_url}/items/ITEM_ID'"
  }
}
