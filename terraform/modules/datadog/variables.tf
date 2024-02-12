variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
}

variable "datadog_app_key" {
  description = "Datadog APP key"
  type        = string
}

# Reference the outputs from the root AWS module
variable "lambda_function_name" {
  description = "Produced lambda function"
  type        = string
}

variable "ApiName" {
  description = "Produced lambda api gateway"
  type        = string
}

variable "aws_account_id" {
  description = "integrated account id"
  type  = string
}