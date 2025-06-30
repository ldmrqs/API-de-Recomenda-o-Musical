output "api_endpoint" {
  value       = "${aws_api_gateway_deployment.music_api_deployment.invoke_url}/recommend"
  description = "URL pública do endpoint de recomendação"
}

output "lambda_bucket_name" {
  value       = aws_s3_bucket.lambda_code.bucket
  description = "Nome do bucket onde o código da Lambda será armazenado"
}
