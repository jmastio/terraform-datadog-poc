terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
}

module "aws_resources" {
  source                  = "../aws"
  aws_region              = var.aws_region
  lambda_function_name    = var.aws_lambda_function_name
}

resource "datadog_monitor" "lambda_monitor" {
  name             = "Lambda Function Monitor"
  type             = "metric alert"
  query            = "lambda.invocations{function_name:${module.aws_resources.lambda_function_name}} > 10"
  message          = "Lambda function is experiencing high invocations"
  escalation_message = "Lambda function still high after 15 minutes, escalating"
  
  thresholds {
    critical = 10
  }

  notify_no_data = false

  tags = ["lambda", "production"]
}
