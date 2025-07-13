# Enterprise Serverless CRUD Application

## Overview

A comprehensive enterprise-grade serverless CRUD application built with AWS services, featuring multi-layer security, comprehensive monitoring, and deployed using Infrastructure as Code with Terraform. This application demonstrates modern serverless architecture patterns and AWS best practices.

## Architecture Overview

### High-Level Architecture

![High-Level Architecture](High-Level%20Architecture.png)


## Features

### Core Functionality
- **Create Items**: Add new items with auto-generated UUIDs
- **Read Items**: Retrieve single items or list all items with pagination
- **Update Items**: Modify existing items with validation
- **Delete Items**: Remove items by ID

### Enterprise Features
- **Multi-layer Security**: IAM roles, API Gateway security, encryption
- **Comprehensive Monitoring**: CloudWatch, X-Ray tracing, custom metrics
- **Error Handling**: Dead Letter Queues, retry logic, graceful degradation
- **Performance Optimization**: Connection pooling, memory tuning
- **Infrastructure as Code**: Complete Terraform deployment
- **Environment Management**: Dev, staging, production configurations

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Python 3.12+ (for local development)
- Git

### Deployment Options

#### Option 1: Terraform Deployment (Recommended)

```bash
# Clone the repository
git clone https://github.com/satispp24/SERVERLESS-CRUD-APP.git
cd terraform-crud-app

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="environments/dev.tfvars"

# Deploy infrastructure
terraform apply -var-file="environments/dev.tfvars"

# Get API Gateway URL
terraform output api_gateway_url
```

#### Option 2: Manual AWS Console Setup

##### 1. Create IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

##### 2. Create Lambda Execution Role
- Create IAM role for Lambda service
- Attach the custom policy created above
- Name: `lambda-apigateway-role`

##### 3. Create Lambda Functions
- Runtime: Python 3.12
- Memory: 256MB
- Timeout: 15 seconds
- Role: `lambda-apigateway-role`

##### 4. Create DynamoDB Table
- Table name: `crud-items`
- Primary key: `id` (String)
- Billing mode: Pay-per-request

##### 5. Create API Gateway
- Type: REST API
- Create resources and methods
- Deploy to stage

## Component Specifications

### API Gateway Configuration
```yaml
API Gateway:
  Type: REST API (Regional)
  Stage: prod
  Throttling:
    Burst Limit: 5000
    Rate Limit: 2000
  
  Endpoints:
    POST /items:
      Description: Create new item
      Request Validation: Enabled
      CORS: Enabled
      
    GET /items:
      Description: Get all items
      Query Parameters: limit, lastKey
      Caching: Optional
      
    GET /items/{id}:
      Description: Get specific item
      Path Parameters: id (required)
      
    PUT /items/{id}:
      Description: Update existing item
      Path Parameters: id (required)
      Request Validation: Enabled
      
    DELETE /items/{id}:
      Description: Delete item
      Path Parameters: id (required)
```

### Lambda Functions Specifications
```yaml
Lambda Functions:
  Runtime: Python 3.12
  Architecture: x86_64
  Memory: 256MB
  Timeout: 15 seconds
  Environment Variables:
    TABLE_NAME: crud-items
    LOG_LEVEL: INFO
  
  Functions:
    create-item:
      Handler: create.lambda_handler
      Description: Creates new items with UUID
      Permissions: dynamodb:PutItem
      
    read-items:
      Handler: read.lambda_handler
      Description: Retrieves items (scan/query)
      Permissions: dynamodb:GetItem, dynamodb:Scan
      
    update-item:
      Handler: update.lambda_handler
      Description: Updates existing items
      Permissions: dynamodb:UpdateItem, dynamodb:GetItem
      
    delete-item:
      Handler: delete.lambda_handler
      Description: Deletes items by ID
      Permissions: dynamodb:DeleteItem
```

### DynamoDB Table Schema
```yaml
DynamoDB Table:
  Name: crud-items
  Billing Mode: PAY_PER_REQUEST
  
  Schema:
    Primary Key:
      Partition Key: id (String)
    
    Attributes:
      id: String (UUID)
      name: String
      description: String (Optional)
      created_at: String (ISO 8601)
      updated_at: String (ISO 8601)
      
  Features:
    Point-in-time Recovery: Enabled
    Server-side Encryption: AWS Managed
    Deletion Protection: Configurable
    Stream: Disabled (Optional)
    
  Global Secondary Indexes:
    created_at-index (Optional):
      Partition Key: created_at
      Projection: ALL
```


## API Usage

### Base URL
After deployment, your API will be available at:
```
https://{api-id}.execute-api.{region}.amazonaws.com/{stage}
```

### Testing with Postman

#### Postman Collection Setup

##### 1. GET All Items
- **Method**: GET
- **URL**: `https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items`
- **Headers**: None required

##### 2. POST Create Item
- **Method**: POST
- **URL**: `https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "name": "Test Item",
  "description": "This is a test item"
}
```

##### 3. GET Single Item
- **Method**: GET
- **URL**: `https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items/{item-id}`
- Replace `{item-id}` with actual ID from create response

##### 4. PUT Update Item
- **Method**: PUT
- **URL**: `https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items/{item-id}`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "name": "Updated Item",
  "description": "Updated description"
}
```

##### 5. DELETE Item
- **Method**: DELETE
- **URL**: `https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items/{item-id}`

### cURL Examples

#### 1. Create Item
```bash
curl -X POST \
  https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Sample Item",
    "description": "This is a sample item"
  }'
```

**Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Sample Item",
  "description": "This is a sample item",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

#### 2. Get All Items
```bash
curl -X GET \
  "https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items?limit=10"
```

**Response:**
```json
{
  "items": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Sample Item",
      "description": "This is a sample item",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ],
  "count": 1
}
```

#### 3. Get Single Item
```bash
curl -X GET \
  "https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items/123e4567-e89b-12d3-a456-426614174000"
```

#### 4. Update Item
```bash
curl -X PUT \
  "https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items/123e4567-e89b-12d3-a456-426614174000" \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Updated Item Name",
    "description": "Updated description"
  }'
```

#### 5. Delete Item
```bash
curl -X DELETE \
  "https://g2tz8qj236.execute-api.us-east-1.amazonaws.com/dev/items/123e4567-e89b-12d3-a456-426614174000"
```

### Error Responses

```json
{
  "error": "Item not found"
}
```

```json
{
  "error": "Request body is required"
}
```

```json
{
  "error": "TABLE_NAME environment variable not set"
}
```

## Data Flow Diagrams

### Create Item Flow
```
┌────────┐    ┌─────────────┐    ┌──────────────┐    ┌──────────┐
│ Client │───▶│ API Gateway │───▶│ Create Lambda│───▶│ DynamoDB │
│        │    │             │    │              │    │  Table   │
│        │    │ • Validate  │    │ • Generate   │    │          │
│        │    │ • Transform │    │   UUID       │    │ • Store  │
│        │    │ • Route     │    │ • Validate   │    │   Item   │
│        │    │             │    │ • Transform  │    │          │
│        │◀───│             │◀───│              │◀───│          │
│        │    │ HTTP 201    │    │ Success      │    │ Response │
└────────┘    └─────────────┘    └──────────────┘    └──────────┘
```

### Read Items Flow
```
┌────────┐    ┌─────────────┐    ┌─────────────┐    ┌──────────┐
│ Client │───▶│ API Gateway │───▶│ Read Lambda │───▶│ DynamoDB │
│        │    │             │    │             │    │  Table   │
│        │    │ • Parse     │    │ • Query/    │    │          │
│        │    │   Query     │    │   Scan      │    │ • Fetch  │
│        │    │ • Route     │    │ • Filter    │    │   Items  │
│        │    │             │    │ • Paginate  │    │          │
│        │◀───│             │◀───│             │◀───│          │
│        │    │ HTTP 200    │    │ Items Array │    │ Results  │
└────────┘    └─────────────┘    └─────────────┘    └──────────┘
```

## Security Architecture

### Multi-Layer Security Model

```
┌─────────────────────────────────────────────────────────────────┐
│                        SECURITY LAYERS                         │
├─────────────────────────────────────────────────────────────────┤
│ Layer 1: Network Security                                       │
│ • VPC Endpoints (Optional)                                      │
│ • WAF Rules (Rate limiting, IP filtering)                      │
│ • Regional API Gateway                                          │
├─────────────────────────────────────────────────────────────────┤
│ Layer 2: Authentication & Authorization                         │
│ • API Keys                                                      │
│ • AWS Cognito (Optional)                                        │
│ • IAM Roles & Policies                                          │
│ • Resource-based Policies                                       │
├─────────────────────────────────────────────────────────────────┤
│ Layer 3: Application Security                                   │
│ • Input Validation                                              │
│ • Request/Response Transformation                               │
│ • CORS Configuration                                            │
│ • Throttling & Rate Limiting                                    │
├─────────────────────────────────────────────────────────────────┤
│ Layer 4: Data Security                                          │
│ • DynamoDB Encryption at Rest                                   │
│ • Encryption in Transit (HTTPS/TLS)                            │
│ • CloudWatch Logs Encryption                                    │
│ • Parameter Store for Secrets                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Monitoring & Observability

### Comprehensive Monitoring Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITY STACK                         │
├─────────────────────────────────────────────────────────────────┤
│ Metrics Layer                                                   │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│
│ │ API Gateway │ │   Lambda    │ │  DynamoDB   │ │   Custom    ││
│ │   Metrics   │ │   Metrics   │ │   Metrics   │ │   Metrics   ││
│ │             │ │             │ │             │ │             ││
│ │• Requests   │ │• Duration   │ │• Read/Write │ │• Business   ││
│ │• Latency    │ │• Errors     │ │  Capacity   │ │  Logic      ││
│ │• Errors     │ │• Memory     │ │• Throttles  │ │• SLA/SLO    ││
│ │• Throttles  │ │• Cold Start │ │• Errors     │ │  Tracking   ││
│ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘│
├─────────────────────────────────────────────────────────────────┤
│ Logging Layer                                                   │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                │
│ │ API Gateway │ │   Lambda    │ │ CloudTrail  │                │
│ │    Logs     │ │    Logs     │ │    Logs     │                │
│ │             │ │             │ │             │                │
│ │• Access     │ │• Function   │ │• API Calls  │                │
│ │  Logs       │ │  Logs       │ │• Data       │                │
│ │• Execution  │ │• Error      │ │  Events     │                │
│ │  Logs       │ │  Logs       │ │• Security   │                │
│ └─────────────┘ └─────────────┘ └─────────────┘                │
├─────────────────────────────────────────────────────────────────┤
│ Tracing Layer                                                   │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │                    AWS X-Ray                                │ │
│ │                                                             │ │
│ │ • End-to-end Request Tracing                                │ │
│ │ • Service Map Visualization                                 │ │
│ │ • Performance Analysis                                      │ │
│ │ • Error Root Cause Analysis                                 │ │
│ │ • Dependency Mapping                                        │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ Alerting Layer                                                  │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                │
│ │ CloudWatch  │ │    SNS      │ │   Lambda    │                │
│ │   Alarms    │ │ Notifications│ │  Webhooks   │                │
│ │             │ │             │ │             │                │
│ │• Threshold  │ │• Email      │ │• Slack      │                │
│ │  Based      │ │• SMS        │ │• Teams      │                │
│ │• Anomaly    │ │• HTTP       │ │• PagerDuty  │                │
│ │  Detection  │ │  Endpoints  │ │• Custom     │                │
│ └─────────────┘ └─────────────┘ └─────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

## Performance Optimization

### Lambda Optimization
- **Cold Start Mitigation**: Provisioned concurrency, connection pooling
- **Memory Tuning**: Right-sized allocation for optimal price/performance
- **Error Handling**: Exponential backoff, circuit breaker patterns
- **Code Optimization**: Minimal dependencies, efficient algorithms

### DynamoDB Optimization
- **Access Patterns**: Single-table design, efficient key structure
- **Capacity Management**: On-demand billing with auto-scaling
- **Query Optimization**: Prefer Query over Scan operations
- **Caching Strategy**: Application-level caching, DAX integration

## Environment Management

### Directory Structure
```
terraform-crud-app/
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── modules/
│   ├── api-gateway/
│   ├── lambda/
│   └── dynamodb/
├── src/
│   ├── create/
│   ├── read/
│   ├── update/
│   └── delete/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

### Terraform Commands
```bash
# Navigate to terraform directory
cd terrraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show current state
terraform show

# Clean up resources
terraform destroy
```

## Testing Strategy

### Unit Tests
```bash
# Run Lambda function unit tests
python -m pytest tests/unit/ -v

# Run with coverage
python -m pytest tests/unit/ --cov=src --cov-report=html
```

### Integration Tests
```bash
# Test API Gateway integration
python -m pytest tests/integration/ -v

# Test DynamoDB operations
python -m pytest tests/integration/test_dynamodb.py -v
```

### End-to-End Tests
```bash
# Full API workflow tests
python -m pytest tests/e2e/ -v --api-url=https://your-api-url
```

## Key Benefits

### Technical Benefits
1. **Serverless**: No server management required
2. **Auto-scaling**: Handles traffic spikes automatically
3. **High Availability**: Multi-AZ deployment by default
4. **Performance**: Sub-second response times
5. **Fault Tolerance**: Built-in redundancy

### Business Benefits
1. **Cost Optimization**: Pay-per-use pricing model
2. **Faster Time-to-Market**: Rapid development and deployment
3. **Reduced Operational Overhead**: Managed services
4. **Global Scale**: AWS global infrastructure
5. **Compliance Ready**: AWS compliance certifications

### Developer Benefits
1. **Simple Architecture**: Easy to understand and maintain
2. **Modern Stack**: Latest AWS services and features
3. **DevOps Ready**: CI/CD pipeline compatible
4. **Observable**: Rich monitoring and debugging tools
5. **Extensible**: Easy to add new features and integrations

## Troubleshooting

### Common Issues

#### Lambda Function Errors
```bash
# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/
aws logs get-log-events --log-group-name /aws/lambda/your-function-name
```

#### API Gateway Issues
```bash
# Test API Gateway directly
aws apigateway test-invoke-method \
  --rest-api-id your-api-id \
  --resource-id your-resource-id \
  --http-method POST
```

#### DynamoDB Issues
```bash
# Check table status
aws dynamodb describe-table --table-name crud-items

# Check table metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits
```

## Cleanup

### Terraform Cleanup
```bash
# Destroy all resources
terraform destroy -var-file="environments/dev.tfvars"

# Confirm destruction
terraform show
```

### Manual Cleanup
If you deployed manually:
1. Delete API Gateway
2. Delete Lambda functions
3. Delete DynamoDB table
4. Delete IAM roles and policies
5. Delete CloudWatch log groups

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support:
- Create an issue in the repository
- Check the AWS documentation
- Review CloudWatch logs for debugging

## Architecture Documentation

For detailed architecture diagrams and technical specifications, see [ARCHITECTURE.md](./ARCHITECTURE.md).


