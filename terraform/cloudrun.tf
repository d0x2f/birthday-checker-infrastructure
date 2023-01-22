resource "google_cloud_run_service" "app" {
  provider = google-beta

  depends_on                 = [google_project_service.run]
  name                       = "birthday-checker"
  location                   = var.region
  autogenerate_revision_name = true

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = 3
      }
    }

    spec {
      containers {
        image = "gcr.io/${data.google_project.project.project_id}/birthday-checker:latest"

        env {
          name  = "FIRESTORE_PROJECT"
          value = data.google_project.project.project_id
        }

        liveness_probe {
          http_get {
            path = "/healthz"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      template.0.spec.0.containers.0.image,
      template.0.metadata.0.annotations,
      template.0.metadata.0.labels,
    ]
  }
}

resource "google_cloud_run_service_iam_member" "noauth" {
  location = google_cloud_run_service.app.location
  service  = google_cloud_run_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
