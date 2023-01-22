resource "google_container_registry" "registry" {
  depends_on = [google_project_service.containerregistry]
}
