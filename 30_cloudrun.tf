resource "google_cloud_run_service" "nginx-hello" {
  provider = google-beta
  project  = module.project-nginx-hello.project_id
  name     = "nginx-hello"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/google-samples/hello-app:1.0"

        liveness_probe {
          failure_threshold     = 5
          initial_delay_seconds = 10
          timeout_seconds       = 3
          period_seconds        = 3

          http_get {
            path = "/health"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      # For valid annotation values and descriptions, see
      # https://cloud.google.com/sdk/gcloud/reference/run/deploy#--ingress
      "run.googleapis.com/ingress" = "all"
    }
  }

  depends_on = [
    module.project-nginx-hello
  ]
}


resource "google_cloud_run_service_iam_member" "all_users" {
  project  = module.project-nginx-hello.project_id
  service  = google_cloud_run_service.nginx-hello.name
  location = google_cloud_run_service.nginx-hello.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}