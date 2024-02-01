data "archive_file" "lambda_zip" {                                                                                                                                                                                   
  type        = "zip"                                                                                                                                                                                                
  source_dir  = "../express-api/"                                                                                                                                                                                         
  output_path = "../express-api/express-api.zip"                                                                                                                                                                         
}                                                                                                                                                                                                                    

resource "aws_lambda_function" "express_api" {
  function_name = "express-api-lambda"
  handler      = "app.handler"
  runtime      = "nodejs14.x"
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

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda" {
  name = "lambda-policy"
  role = aws_iam_role.lambda_exec.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_api_gateway_rest_api" "express_api" {
  name        = "express-api"
  description = "Express API"
}

resource "aws_api_gateway_resource" "express_api_root" {
  rest_api_id = aws_api_gateway_rest_api.express_api.id
  parent_id   = aws_api_gateway_rest_api.express_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "express_api" {
  rest_api_id   = aws_api_gateway_rest_api.express_api.id
  resource_id   = aws_api_gateway_resource.express_api_root.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "express_api" {
  rest_api_id             = aws_api_gateway_rest_api.express_api.id
  resource_id             = aws_api_gateway_resource.express_api_root.id
  http_method             = aws_api_gateway_method.express_api.http_method
  integration_http_method = "POST"  # or "GET", "PUT", etc.
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.express_api.invoke_arn
}

resource "aws_api_gateway_deployment" "express_api" {
  depends_on = [aws_api_gateway_integration.express_api]

  rest_api_id = aws_api_gateway_rest_api.express_api.id
  stage_name  = "prod"  # or any other desired stage name
}

resource "aws_route53_record" "express_api" {
  zone_id = "Z069622921MYYVP9QMGLQ"  # Update with your Route 53 hosted zone ID
  name    = "api-tf-datadog-poc.jmastio.com"  # Update with your desired domain/subdomain
  type    = "CNAME"

  records = [aws_api_gateway_deployment.express_api.invoke_url]
  ttl     = 300
}
