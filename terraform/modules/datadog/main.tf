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

resource "datadog_monitor" "api_gateway_hits" {
  name             = "API Gateway Hits Monitor"
  type             = "metric alert"
  message          = "API Gateway is experiencing high traffic"
  escalation_message = "API Gateway still high after 15 minutes, escalating"
  
  query = "avg(last_15m):sum:aws.apigateway.api_request.count{*} > 100"

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
