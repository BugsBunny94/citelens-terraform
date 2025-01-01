resource "google_cloud_run_service" "rein_frontend_cloud_run" {
  name     = "rein-frontend"
  location = local.region

  template {
    metadata {
      annotations = {
        "force-redeploy" = local.redeploy_rein_frontend_cloud_run ? timestamp() : 0 
      }
    }    
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.my_repository.name}/rein-frontend" 
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
resource "google_cloud_run_service_iam_member" "rein_frontend_cloud_run_invoker" {
  service  = google_cloud_run_service.rein_frontend_cloud_run.name
  location = google_cloud_run_service.rein_frontend_cloud_run.location
  role     = "roles/run.invoker"
  member   = "allUsers" # Rendre le service accessible publiquement
}
