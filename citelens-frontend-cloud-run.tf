variable "redeploy_citelens_frontend_cloud_run" {
  default = true
}

resource "google_cloud_run_service" "citelens_frontend_cloud_run" {
  name     = "citelens-frontend"
  location = local.region

  template {
    metadata {
      annotations = {
        "force-redeploy" = var.redeploy_citelens_frontend_cloud_run ? timestamp() : 0 
      }
    }    
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.my_repository.name}/citelens-frontend" 
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
resource "google_cloud_run_service_iam_member" "citelens_frontend_cloud_run_invoker" {
  service  = google_cloud_run_service.citelens_frontend_cloud_run.name
  location = google_cloud_run_service.citelens_frontend_cloud_run.location
  role     = "roles/run.invoker"
  member   = "allUsers" # Rendre le service accessible publiquement
}
