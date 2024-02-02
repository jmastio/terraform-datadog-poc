variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for API Gateway deployment"
  type        = string
}

variable "aws_lambda_function_name" {
  description = "Name of the AWS Lambda function"
  type        = string
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_gateway_description" {
  description = "Description of the API Gateway"
  type        = string
}

