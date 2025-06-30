import boto3
import json
import os
import uuid
from datetime import datetime

# Bedrock no sa-east-1 com Claude 3
bedrock = boto3.client(
    service_name="bedrock-runtime",
    region_name="sa-east-1"
)

dynamodb = boto3.resource("dynamodb", region_name="sa-east-1")
table_name = os.environ.get("HISTORY_TABLE_NAME")
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    user_input = "Me recomende uma música com vibe tranquila e melodia marcante."

    body = {
        "anthropic_version": "bedrock-2023-05-31",
        "messages": [
            {"role": "user", "content": user_input}
        ],
        "max_tokens": 200,
        "temperature": 0.8,
        "top_k": 250,
        "top_p": 0.9
    }

    response = bedrock.invoke_model(
        modelId="anthropic.claude-3-sonnet-20240229-v1:0",
        body=json.dumps(body),
        contentType="application/json",
        accept="application/json"
    )

    response_body = json.loads(response['body'].read())
    musica_recomendada = response_body['content'][0]['text'].strip()

    # Salvar no DynamoDB
    table.put_item(
        Item={
            "usuario_id": "larissa123",
            "timestamp": datetime.utcnow().isoformat(),
            "musica_recomendada": musica_recomendada
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "musica": musica_recomendada
        })
    }
