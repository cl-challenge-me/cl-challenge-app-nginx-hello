resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  project               = module.project-nginx-hello.project_id
  name                  = "${var.app_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.nginx-hello.name
  }
}

resource "google_compute_region_backend_service" "default" {
  project               = module.project-nginx-hello.project_id
  region                = var.region
  name                  = "${var.app_name}-${var.region}-svc"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
    capacity_scaler = "1.0"
    balancing_mode = "UTILIZATION"
  }

}