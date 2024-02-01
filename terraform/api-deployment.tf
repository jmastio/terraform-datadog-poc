resource "aws_lambda_function" "express_api" {
  function_name = "express-api-lambda"
  handler      = "app.handler"
  runtime      = "nodejs14.x"
  filename     = "../express-api/express-api.zip"
  source_code_hash = filebase64("../express-api/express-api.zip")

  role = aws_iam_role.lambda_exec.arn

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
