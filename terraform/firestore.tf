resource "google_app_engine_application" "app" {
  depends_on    = [google_project_service.appengine]
  location_id   = var.region
  project       = data.google_project.project.project_id
  database_type = "CLOUD_FIRESTORE"
}
