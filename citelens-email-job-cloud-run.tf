locals {
  count_citelens_email_job_cloud_run = 1
}

resource "google_cloud_run_service" "citelens_email_job_cloud_run" {
  name     = "citelens-email-job"
  location = local.region
  count    = local.count_citelens_email_job_cloud_run

  template {
    metadata {
      annotations = {
        "force-redeploy" = local.redeploy_citelens_email_job_cloud_run ? timestamp() : 0 
      }
    }    
    spec {
      containers {
        image = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.my_repository.name}/citelensemailjob" 
        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1"
          }
        }
      }
      timeout_seconds = 3600
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Autoriser l'accès public à Cloud Run
resource "google_cloud_run_service_iam_member" "citelens_email_job_cloud_run_invoker" {
  count    = local.count_citelens_email_job_cloud_run > 0 ? 1 : 0
  service  = google_cloud_run_service.citelens_email_job_cloud_run[0].name
  location = google_cloud_run_service.citelens_email_job_cloud_run[0].location
  role     = "roles/run.invoker"
  member   = "allUsers" # Rendre le service accessible publiquement
}

resource "google_cloud_scheduler_job" "citelens_email_job_trigger" {
  name     = "citelens-email-job-trigger"
  schedule = "10 9 * * *" 

  http_target {
    http_method = "GET"
    uri         = "${google_cloud_run_service.citelens_email_job_cloud_run[0].status[0].url}/job/run"
  }
  count = 1
}

