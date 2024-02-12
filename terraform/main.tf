module "aws_resources" {
  source                  = "./modules/aws"
  aws_region              = var.aws_region
  route53_zone_id         = var.route53_zone_id
  domain_name             = var.domain_name
  aws_lambda_function_name = var.lambda_gateway_name
  api_gateway_name        = var.lambda_gateway_name
  api_gateway_description  = var.api_gateway_description
  # api_gateway_path_part    = var.api_gateway_path_part
  # api_gateway_stage_name   = var.api_gateway_stage_name
  # route53_ttl             = var.route53_ttl
}

module "datadog_resources" {
  source = "./modules/datadog"
  datadog_api_key = var.datadog_api_key
  datadog_app_key = var.datadog_app_key
  aws_account_id = var.aws_account_id
  lambda_function_name = module.aws_resources.lambda_function_name
  ApiName = module.aws_resources.ApiName
}