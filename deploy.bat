@echo off
setlocal enabledelayedexpansion

echo 🚀 CRUD Application Deployment Script
echo ======================================

REM Check if Terraform is installed
terraform version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Terraform is not installed. Please install Terraform first.
    echo    Visit: https://www.terraform.io/downloads.html
    pause
    exit /b 1
)

REM Check if AWS CLI is installed
aws --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AWS CLI is not installed. Please install AWS CLI first.
    echo    Visit: https://aws.amazon.com/cli/
    pause
    exit /b 1
)

REM Check AWS credentials
aws sts get-caller-identity >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AWS credentials not configured. Please run 'aws configure' first.
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed
echo.

REM Get current AWS account and region
for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT=%%i
for /f "tokens=*" %%i in ('aws configure get region') do set AWS_REGION=%%i

echo 📋 Deployment Information:
echo    AWS Account: %AWS_ACCOUNT%
echo    AWS Region: %AWS_REGION%
echo.

set /p PROCEED="Do you want to proceed with the deployment? (y/N): "
if /i not "%PROCEED%"=="y" (
    echo ❌ Deployment cancelled.
    pause
    exit /b 1
)

echo.
echo 🔧 Initializing Terraform...
terraform init
if %errorlevel% neq 0 (
    echo ❌ Terraform init failed.
    pause
    exit /b 1
)

echo.
echo 📋 Planning deployment...
terraform plan
if %errorlevel% neq 0 (
    echo ❌ Terraform plan failed.
    pause
    exit /b 1
)

echo.
set /p APPLY="Do you want to apply these changes? (y/N): "
if /i not "%APPLY%"=="y" (
    echo ❌ Deployment cancelled.
    pause
    exit /b 1
)

echo.
echo 🚀 Deploying infrastructure...
terraform apply -auto-approve
if %errorlevel% neq 0 (
    echo ❌ Terraform apply failed.
    pause
    exit /b 1
)

echo.
echo ✅ Deployment completed successfully!
echo.
echo 📝 Important outputs:
terraform output

echo.
echo 🎉 Your CRUD API is now ready!
echo.
echo 📚 Next steps:
echo    1. Test the API using the curl examples shown above
echo    2. Check the README.md for detailed usage instructions
echo    3. Monitor your Lambda functions in CloudWatch
echo.
echo 🧹 To clean up resources later, run: terraform destroy

pause
