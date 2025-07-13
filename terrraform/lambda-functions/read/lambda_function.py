import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    Lambda function to read an item from DynamoDB
    """
    try:
        # Get table name from environment variable
        table_name = os.environ.get('TABLE_NAME')
        
        if not table_name:
            return {
                'statusCode': 500,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'TABLE_NAME environment variable not set'
                })
            }
        
        # Extract item ID from path parameters
        item_id = None
        if 'pathParameters' in event and event['pathParameters']:
            item_id = event['pathParameters'].get('id')
        
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        
        # Get DynamoDB table
        table = dynamodb.Table(table_name)
        
        if item_id:
            # Get single item
            response = table.get_item(Key={'id': item_id})
            
            if 'Item' in response:
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps(response['Item'])
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
        else:
            # Scan all items
            limit = int(query_params.get('limit', 50))
            response = table.scan(Limit=limit)
            items = response.get('Items', [])
            
            result = {
                'items': items,
                'count': len(items)
            }
            
            if 'LastEvaluatedKey' in response:
                result['lastKey'] = response['LastEvaluatedKey']
            
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(result)
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
