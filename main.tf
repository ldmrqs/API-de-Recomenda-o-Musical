provider "aws" {
  region = "sa-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lambda_code" {
  bucket = "music-recs-lambda-code-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_iam_role" "lambda_exec" {
  name = "music-recs-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "music-recs-policy"
  description = "Lambda policy for S3 and DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.lambda_code.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "recommendation" {
  function_name = "music-recs-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  s3_bucket = aws_s3_bucket.lambda_code.bucket
  s3_key    = "lambda/lambda_function.zip"

  source_code_hash = filebase64sha256(var.lambda_package_file)

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.history_table.name
    }
  }
}

resource "aws_dynamodb_table" "history_table" {
  name           = "APIMusicalHistory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_api_gateway_rest_api" "music_api" {
  name        = "MusicRecommendationAPI"
  description = "API para recomendar músicas usando IA"
}

resource "aws_api_gateway_resource" "recommend" {
  rest_api_id = aws_api_gateway_rest_api.music_api.id
  parent_id   = aws_api_gateway_rest_api.music_api.root_resource_id
  path_part   = "recommend"
}

resource "aws_api_gateway_method" "recommend_post" {
  rest_api_id   = aws_api_gateway_rest_api.music_api.id
  resource_id   = aws_api_gateway_resource.recommend.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.music_api.id
  resource_id = aws_api_gateway_resource.recommend.id
  http_method = aws_api_gateway_method.recommend_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.recommendation.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.recommendation.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.music_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "music_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.music_api.id

  triggers = {
    redeploy = sha1(jsonencode(aws_api_gateway_method.recommend_post))
  }

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_stage" "music_api_stage" {
  deployment_id = aws_api_gateway_deployment.music_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.music_api.id
  stage_name    = "prod"
}
