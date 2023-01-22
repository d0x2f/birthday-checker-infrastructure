resource "google_monitoring_service" "service" {
  service_id = "cloud-run-monitor"
  basic_service {
    service_type = "CLOUD_RUN"
    service_labels = {
      service_name = google_cloud_run_service.app.name
      location     = google_cloud_run_service.app.location
    }
  }
}

resource "google_monitoring_slo" "latency" {
  service = google_monitoring_service.service.service_id

  display_name = "Latency < 1s"

  goal            = 0.99
  calendar_period = "DAY"

  basic_sli {
    latency {
      threshold = "1s"
    }
  }
}

resource "google_monitoring_slo" "availability" {
  service = google_monitoring_service.service.service_id

  display_name = "Availability > 99%"

  goal            = 0.99
  calendar_period = "DAY"

  basic_sli {
    availability {
      enabled = true
    }
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "Latency 95th percentile > 800ms"
  combiner     = "OR"
  conditions {
    display_name = "High Request Latencies"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/request_latencies\" AND resource.type=\"cloud_run_revision\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = "800"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_95"
      }
    }
  }
}

resource "google_monitoring_alert_policy" "availability_slo_burn_rate" {
  display_name = "Burn rate on SLO '${google_monitoring_slo.availability.display_name}'"
  combiner     = "AND"
  conditions {
    display_name = "SLO burn rate alert for availability SLO"
    condition_threshold {
      filter          = "select_slo_burn_rate(\"${google_monitoring_slo.availability.name}\", 60m)"
      threshold_value = 10
      comparison      = "COMPARISON_GT"
      duration        = "60s"
    }
  }
}

resource "google_monitoring_alert_policy" "latency_slo_burn_rate" {
  display_name = "Burn rate on SLO '${google_monitoring_slo.latency.display_name}'"
  combiner     = "AND"
  conditions {
    display_name = "SLO burn rate alert for latency SLO"
    condition_threshold {
      filter          = "select_slo_burn_rate(\"${google_monitoring_slo.latency.name}\", 60m)"
      threshold_value = 10
      comparison      = "COMPARISON_GT"
      duration        = "60s"
    }
  }
}
