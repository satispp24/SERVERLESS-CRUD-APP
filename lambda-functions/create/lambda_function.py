import json
import boto3
import uuid
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    Lambda function to create an item in DynamoDB
    """
    try:
        # Parse the request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        table_name = body.get('tableName')
        item_data = body.get('item', {})
        
        if not table_name:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'tableName is required'
                })
            }
        
        # Generate ID if not provided
        if 'id' not in item_data:
            item_data['id'] = str(uuid.uuid4())
        
        # Add timestamp
        item_data['createdAt'] = datetime.utcnow().isoformat()
        item_data['updatedAt'] = datetime.utcnow().isoformat()
        
        # Get DynamoDB table
        table = dynamodb.Table(table_name)
        
        # Put item in DynamoDB
        response = table.put_item(Item=item_data)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Item created successfully',
                'item': item_data,
                'dynamoResponse': response.get('ResponseMetadata', {})
            })
        }
        
    except ClientError as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': f'DynamoDB error: {str(e)}'
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': f'Internal server error: {str(e)}'
            })
        }
