provider "aws" {
  region = var.aws_region
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../express-api/"
  output_path = "../express-api/express-api.zip"
}

resource "aws_lambda_function" "express_api" {
  function_name    = var.aws_lambda_function_name
  handler          = "app.handler"
  runtime          = "nodejs14.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  lifecycle {
    ignore_changes = [
      filename,  # Exclude the filename attribute from changes
    ]
  }

  depends_on = [aws_iam_role_policy.lambda]
}

resource "random_pet" "component_name" {
  length    = 2
  separator = "-"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role-${random_pet.component_name.id}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = "sts:AssumeRole",
        Effect   = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "lambda" {
  name = "lambda-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_apigatewayv2_api" "express_api" {
  name        = var.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "express_api" {
  api_id    = aws_apigatewayv2_api.express_api.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.express_api.id}"
}

resource "aws_apigatewayv2_integration" "express_api" {
  api_id          = aws_apigatewayv2_api.express_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.express_api.arn
}

resource "aws_apigatewayv2_stage" "express_api" {
  api_id      = aws_apigatewayv2_api.express_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_route53_record" "express_api" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "CNAME"

  records = [aws_apigatewayv2_api.express_api.api_endpoint]
  ttl     = "300"
}
