terraform {
  backend "gcs" {
    project = var.project_id
    prefix  = "terraform/state"
  }
}
