locals {
  count_blog_backend_cloud_run = 1
}

resource "google_cloud_run_service" "blog_backend_cloud_run" {
  name     = "blog-backend"
  location = local.region
  count    = local.count_blog_backend_cloud_run

  template {
    metadata {
      annotations = {
        "force-redeploy" = local.redeploy_blog_backend_cloud_run ? timestamp() : 0 
      }
    }
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.my_repository.name}/blogws" 
        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1"
          }
        }
        env {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "production"
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
resource "google_cloud_run_service_iam_member" "blog_invoker" {
  count    = local.count_blog_backend_cloud_run > 0 ? 1 : 0
  service  = google_cloud_run_service.blog_backend_cloud_run[0].name
  location = google_cloud_run_service.blog_backend_cloud_run[0].location
  role     = "roles/run.invoker"
  member   = "allUsers" # Rendre le service accessible publiquement
}
