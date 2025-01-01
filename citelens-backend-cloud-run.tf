locals {
  count_citelens_backend_cloud_run = 1
  citelens_backend_version = "0.0.4"
}

resource "google_cloud_run_service" "citelens_backend_cloud_run" {
  name     = "citelens-backend"
  location = local.region
  count    = local.count_citelens_backend_cloud_run

  template {
    metadata {
      annotations = {
        "force-redeploy" = local.redeploy_citelens_backend_cloud_run ? timestamp() : 0 
        "autoscaling.knative.dev/minScale" = "1"
      }
    }    
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.my_repository.name}/citelens" 
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
resource "google_cloud_run_service_iam_member" "invoker" {
  count    = local.count_citelens_backend_cloud_run > 0 ? 1 : 0
  service  = google_cloud_run_service.citelens_backend_cloud_run[0].name
  location = google_cloud_run_service.citelens_backend_cloud_run[0].location
  role     = "roles/run.invoker"
  member   = "allUsers" # Rendre le service accessible publiquement
}
