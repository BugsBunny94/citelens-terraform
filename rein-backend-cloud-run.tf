locals {
  count_rein_backend_cloud_run = 1
  rein_backend_version = "0.0.4"
}

resource "google_cloud_run_service" "rein_backend_cloud_run" {
  name     = "rein-backend"
  location = local.region
  count    = local.count_rein_backend_cloud_run

  template {
    metadata {
      annotations = {
        "force-redeploy" = local.redeploy_rein_backend_cloud_run ? timestamp() : 0 
        "autoscaling.knative.dev/minScale" = "1"
      }
    }    
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.my_repository.name}/rein-backend" 
        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1"
          }
        }
      }    
      timeout_seconds = 300
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Autoriser l'accès public à Cloud Run
resource "google_cloud_run_service_iam_member" "rein_invoker" {
  count    = local.count_rein_backend_cloud_run > 0 ? 1 : 0
  service  = google_cloud_run_service.rein_backend_cloud_run[0].name
  location = google_cloud_run_service.rein_backend_cloud_run[0].location
  role     = "roles/run.invoker"
  member   = "allUsers" # Rendre le service accessible publiquement
}
