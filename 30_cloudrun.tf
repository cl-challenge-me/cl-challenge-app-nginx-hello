resource "google_cloud_run_service" "nginx-hello" {
  for_each = toset(var.regions)
  provider = google-beta
  project  = module.project.project_id
  name     = var.app_name
  location = each.key

  template {
    spec {
      service_account_name = google_service_account.cloudrun_sa.email
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
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  depends_on = [
    module.project
  ]
}

resource "google_cloud_run_service_iam_member" "all_users" {
  for_each = toset(var.regions)
  project  = module.project.project_id
  service  = google_cloud_run_service.nginx-hello[each.key].name
  location = google_cloud_run_service.nginx-hello[each.key].location
  role     = "roles/run.invoker"
  member   = "allUsers"
}