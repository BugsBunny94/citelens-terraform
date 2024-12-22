resource "google_artifact_registry_repository" "my_repository" {
  location      = local.region
  repository_id = "my-repository"
  format        = "DOCKER"
}