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

variable "lambda_gateway_name" {
  description = "Name of the AWS Lambda function and the API gatewat "
  type        = string
}

variable "api_gateway_description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
}

variable "datadog_app_key" {
  description = "Datadog app key"
  type        = string
}