#!/bin/bash

# CRUD Application Deployment Script
# This script helps deploy the serverless CRUD application using Terraform

set -e

echo "🚀 CRUD Application Deployment Script"
echo "======================================"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install AWS CLI first."
    echo "   Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Get current AWS account and region
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

echo "📋 Deployment Information:"
echo "   AWS Account: $AWS_ACCOUNT"
echo "   AWS Region: $AWS_REGION"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

echo ""
echo "🔧 Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning deployment..."
terraform plan

echo ""
read -p "Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

echo ""
echo "🚀 Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "📝 Important outputs:"
terraform output

echo ""
echo "🎉 Your CRUD API is now ready!"
echo ""
echo "📚 Next steps:"
echo "   1. Test the API using the curl examples shown above"
echo "   2. Check the README.md for detailed usage instructions"
echo "   3. Monitor your Lambda functions in CloudWatch"
echo ""
echo "🧹 To clean up resources later, run: terraform destroy"
