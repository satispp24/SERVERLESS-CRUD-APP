import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    Lambda function to read an item from DynamoDB
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
        operation = body.get('operation', 'get')  # 'get' for single item, 'scan' for all items
        
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
        
        # Get DynamoDB table
        table = dynamodb.Table(table_name)
        
        if operation == 'scan':
            # Scan all items
            response = table.scan()
            items = response.get('Items', [])
            
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'items': items,
                    'count': len(items)
                })
            }
        else:
            # Get single item
            if not item_id:
                return {
                    'statusCode': 400,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'error': 'id is required for get operation'
                    })
                }
            
            response = table.get_item(
                Key={'id': item_id}
            )
            
            if 'Item' in response:
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'item': response['Item']
                    })
                }
            else:
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
