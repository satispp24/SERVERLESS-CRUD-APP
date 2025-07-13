# CRUD Application with Terraform

This project creates a complete serverless CRUD (Create, Read, Update, Delete) application using AWS services with Terraform automation.

## Architecture

The application consists of:
- **API Gateway**: REST API with separate endpoints for each CRUD operation
- **Lambda Functions**: Four separate functions for Create, Read, Update, and Delete operations
- **DynamoDB**: NoSQL database for data storage
- **IAM Roles & Policies**: Secure access control

## Project Structure

```
terraform-crud-app/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── dynamodb.tf            # DynamoDB table configuration
├── iam.tf                 # IAM roles and policies
├── lambda.tf              # Lambda functions configuration
├── api-gateway.tf         # API Gateway configuration
├── api-deployment.tf      # API Gateway deployment
├── outputs.tf             # Output values
├── README.md              # This file
└── lambda-functions/      # Lambda function source code
    ├── create/
    │   └── lambda_function.py
    ├── read/
    │   └── lambda_function.py
    ├── update/
    │   └── lambda_function.py
    └── delete/
        └── lambda_function.py
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** installed (version >= 1.0)
3. **AWS Account** with necessary permissions

## Deployment Instructions

### 1. Clone and Navigate
```bash
cd terraform-crud-app
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the Plan
```bash
terraform plan
```

### 4. Deploy the Infrastructure
```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 5. Note the Outputs
After successful deployment, Terraform will display important information including:
- API Gateway URL
- DynamoDB table name
- Lambda function names
- Example curl commands

## API Endpoints

The API provides the following endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/items` | Create a new item |
| GET | `/items` | Get all items |
| GET | `/items/{id}` | Get a specific item |
| PUT | `/items/{id}` | Update an item |
| DELETE | `/items/{id}` | Delete an item |

## Usage Examples

### Create an Item
```bash
curl -X POST https://your-api-id.execute-api.region.amazonaws.com/dev/items \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "crud-items",
    "item": {
      "name": "Sample Item",
      "description": "This is a sample item",
      "category": "test"
    }
  }'
```

### Get All Items
```bash
curl -X GET "https://your-api-id.execute-api.region.amazonaws.com/dev/items?tableName=crud-items&operation=scan"
```

### Get a Specific Item
```bash
curl -X GET "https://your-api-id.execute-api.region.amazonaws.com/dev/items/ITEM_ID?tableName=crud-items"
```

### Update an Item
```bash
curl -X PUT https://your-api-id.execute-api.region.amazonaws.com/dev/items/ITEM_ID \
  -H "Content-Type: application/json" \
  -d '{
    "tableName": "crud-items",
    "id": "ITEM_ID",
    "item": {
      "name": "Updated Item",
      "description": "This item has been updated"
    }
  }'
```

### Delete an Item
```bash
curl -X DELETE "https://your-api-id.execute-api.region.amazonaws.com/dev/items/ITEM_ID?tableName=crud-items&id=ITEM_ID"
```

## Configuration

You can customize the deployment by modifying variables in `variables.tf` or by passing them during deployment:

```bash
terraform apply -var="project_name=my-crud-app" -var="environment=prod" -var="aws_region=us-west-2"
```

### Available Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for resources | `us-east-1` |
| `project_name` | Name of the project | `crud-app` |
| `environment` | Environment name | `dev` |
| `table_name` | DynamoDB table name | `crud-items` |

## Lambda Functions

Each Lambda function is designed for a specific operation:

### Create Function
- Generates UUID if ID not provided
- Adds timestamps (createdAt, updatedAt)
- Validates required fields

### Read Function
- Supports both single item retrieval and scanning all items
- Uses query parameters for operation type

### Update Function
- Checks if item exists before updating
- Updates timestamp automatically
- Prevents updating the primary key

### Delete Function
- Verifies item exists before deletion
- Returns the deleted item data

## Security

The application implements security best practices:
- IAM roles with least privilege access
- Lambda functions can only access the specific DynamoDB table
- API Gateway uses AWS_PROXY integration for secure Lambda invocation

## Monitoring

CloudWatch log groups are automatically created for each Lambda function with 14-day retention.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure your AWS credentials have sufficient permissions
2. **Region Mismatch**: Verify the AWS region in your configuration
3. **Resource Conflicts**: Check for existing resources with the same names

### Logs

Check CloudWatch logs for Lambda function execution details:
- `/aws/lambda/crud-app-create`
- `/aws/lambda/crud-app-read`
- `/aws/lambda/crud-app-update`
- `/aws/lambda/crud-app-delete`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
