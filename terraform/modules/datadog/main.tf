terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

resource "datadog_integration_aws" "sandbox_integration" {
  account_id = var.aws_account_id
  role_name   = "DatadogAWSIntegrationRole"
}

resource "datadog_monitor" "api_gateway_hits" {
  name             = "API Gateway Hits Monitor"
  type             = "metric alert"
  message          = "API Gateway is experiencing high traffic"
  escalation_message = "API Gateway still high after 15 minutes, escalating"
  
  query = "avg(last_15m):sum:aws.apigateway.api_request.count{$ApiName} by {ApiName} > 100"

  evaluation_delay = 900 // 15 minutes
  timeout_h        = 1

  monitor_thresholds {
    critical = 100
  }

  notify_no_data      = false
  require_full_window = false
  renotify_interval   = 0
  notify_audit        = false
  include_tags        = true

  tags = ["api_gateway", "production"]
}

resource "datadog_service_level_objective" "api_gateway_slo" {
  name              = "API Gateway SLO"
  description       = "Service Level Objective for API Gateway"
  type              = "monitor"
  monitor_ids       = [datadog_monitor.api_gateway_hits.id]
 thresholds {
    timeframe = "7d"
    target    = 99.9
    warning   = 99.99
  }
  tags              = ["api_gateway", "production"]
}
