import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    Lambda function to delete an item from DynamoDB
    """
    try:
        # Parse the request body or query parameters
        if 'body' in event and event['body']:
            body = json.loads(event['body'])
        elif 'queryStringParameters' in event and event['queryStringParameters']:
            body = event['queryStringParameters']
        else:
            body = event
        
        table_name = body.get('tableName')
        item_id = body.get('id')
        
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
        
        if not item_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'id is required'
                })
            }
        
        # Get DynamoDB table
        table = dynamodb.Table(table_name)
        
        # Check if item exists before deleting
        existing_item = table.get_item(Key={'id': item_id})
        if 'Item' not in existing_item:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Item not found'
                })
            }
        
        # Delete item from DynamoDB
        response = table.delete_item(
            Key={'id': item_id},
            ReturnValues='ALL_OLD'
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Item deleted successfully',
                'deletedItem': response.get('Attributes', {})
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
