#!/bin/bash

set -e

echo "📦 Empacotando Lambda com Claude 3 Sonnet..."

# Ir para a raiz do projeto (API-Docker)
cd "$(dirname "$0")/../.."

# Aponta o zip para ser recriado do zero
rm -f lambda_function.zip

# Empacota os arquivos da função Lambda
zip lambda_function.zip lambda/lambda_function.py lambda/requirements.txt

echo "✅ Zip criado com sucesso."

# Coleta o nome do bucket gerado pelo Terraform
BUCKET_NAME=$(terraform output -raw lambda_bucket_name)
S3_KEY="lambda/lambda_function.zip"

echo "⬆️ Enviando lambda_function.zip para S3..."
aws s3 cp lambda_function.zip s3://$BUCKET_NAME/$S3_KEY --profile apimusical

echo "🎉 Upload finalizado com sucesso!"
