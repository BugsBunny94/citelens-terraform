resource "google_monitoring_uptime_check_config" "citelens_backend_cloud_run_uptime_check" {
  display_name = "citelens-backend-cloud-run-uptime-check"
  timeout = "10s"
  period  = "60s"

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = local.project_id
      host       = replace(google_cloud_run_service.citelens_backend_cloud_run[0].status[0].url, "https://", "")
    }
  }

  http_check {
    path    = "/actuator/health"
    port    = 8080
    use_ssl = true
  }
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "email-notification-channel"
  type         = "email"

  labels = {
    email_address = "aymane.bouziane.pro@gmail.com"
  }
}


resource "google_monitoring_alert_policy" "uptime_alert_policy" {
  display_name = "citelens-backend-cloud-run-uptime-alert"

  combiner = "OR"

  conditions {
    display_name = "uptime-check-failed"
    condition_threshold {
      # Filter for the uptime check metric
      filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\""

      # Trigger an alert if the service is down
      comparison = "COMPARISON_LT"

      # How long the condition must be met to trigger the alert
      duration = "60s"

      # Threshold for triggering the alert
      threshold_value = 1  # Alert if fraction is less than 1

      aggregations {
        alignment_period   = "60s"                  # Aggregate data over 1 minute
        per_series_aligner = "ALIGN_FRACTION_TRUE"  # Use the fraction of true values
      }
    }
  }

  # Notification channel to send alerts
  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]
}
