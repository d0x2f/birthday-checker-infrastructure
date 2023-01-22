terraform {
  required_version = "~> 1.3.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.49.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

provider "google" {
  region  = var.region
  project = var.project_id
}

provider "google-beta" {
  region  = var.region
  project = var.project_id
}
