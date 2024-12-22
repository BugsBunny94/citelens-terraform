provider "google" {
  project = local.project_id
  credentials = "${file("gcp-api-key.json")}"
  region  = local.region
  zone    = local.zone
}
