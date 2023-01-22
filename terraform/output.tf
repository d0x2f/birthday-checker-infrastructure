output "deployer_key" {
  description = "Google service account credentials for deploying new cloud-run revisions."
  value       = base64decode(google_service_account_key.deployer_key.private_key)
  sensitive   = true
}
