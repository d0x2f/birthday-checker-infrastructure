resource "google_service_account" "deployer" {
  account_id   = "app-deployer"
  display_name = "App Deployer"
}

resource "google_service_account_key" "deployer_key" {
  service_account_id = google_service_account.deployer.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_cloud_run_service_iam_member" "deployer" {
  location = google_cloud_run_service.app.location
  service  = google_cloud_run_service.app.name
  role     = "roles/run.developer"
  member   = google_service_account.deployer.member
}

resource "google_service_account_iam_binding" "deployer_token_creator" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    google_service_account.deployer.member,
  ]
}

data "google_compute_default_service_account" "default" {
  depends_on = [google_project_service.compute]
}

resource "google_service_account_iam_binding" "impersonate_compute" {
  service_account_id = data.google_compute_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    google_service_account.deployer.member,
  ]
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.admin"
  members = [
    google_service_account.deployer.member,
  ]
}
