variable "lambda_package_file" {
  description = "Path local do arquivo .zip da função Lambda"
  type        = string
  default     = "lambda/lambda_function.zip"
}

variable "lambda_s3_key" {
  description = "Nome do arquivo zip enviado ao bucket"
  type        = string
  default     = "lambda/lambda_function.zip"
}
