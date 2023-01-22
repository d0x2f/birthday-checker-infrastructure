output "deployer_key" {
  description = "Google service account credentials for deploying new cloud-run revisions."
  value       = base64decode(google_service_account_key.deployer_key.private_key)
  sensitive   = true
}

output "app_url" {
  description = "Cloud run URL serving the app."
  value       = google_cloud_run_service.app.status.0.url
}
