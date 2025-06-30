output "api_endpoint" {
  value = "${aws_api_gateway_stage.music_api_stage.invoke_url}/recommend"
}

output "lambda_bucket_name" {
  value       = aws_s3_bucket.lambda_code.bucket
  description = "Nome do bucket onde o código da Lambda será armazenado"
}
