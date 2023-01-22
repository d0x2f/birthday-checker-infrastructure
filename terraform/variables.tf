variable "region" {
  description = "The target GCP region."
  default     = "europe-west2"
  type        = string
}

variable "project_id" {
  description = "GCP project id."
  type        = string
}
