# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  project = module.project-nginx-hello.project_id

  name          = "l7-ilb-proxy-subnet"
  ip_cidr_range = cidrsubnet(var.project_ip_cidr_range, 2, 2)
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = module.project-nginx-hello.network_id
}

# forwarding rule
resource "google_compute_forwarding_rule" "ilb" {
  project = module.project-nginx-hello.project_id

  name                  = "${var.app_name}-l7-ilb-${var.region}"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.default.id
  network               = module.project-nginx-hello.network_id
  subnetwork            = module.project-nginx-hello.subnet_id
  network_tier          = "PREMIUM"
  allow_global_access   = true
}

# HTTP target proxy
resource "google_compute_region_target_https_proxy" "default" {
  project = module.project-nginx-hello.project_id

  name             = "${var.app_name}-lb-https-proxy-${var.region}"
  url_map          = google_compute_region_url_map.default.id
  ssl_certificates = [google_compute_region_ssl_certificate.ilb.id]
  depends_on = [
    google_compute_subnetwork.proxy_subnet
  ]
}

resource "google_compute_region_url_map" "default" {
  project         = module.project-nginx-hello.project_id
  name            = "${var.app_name}-lb-url-map-${var.region}"
  default_service = google_compute_region_backend_service.ilb-backend.id
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  project               = module.project-nginx-hello.project_id
  name                  = "${var.app_name}-neg"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.nginx-hello.name
  }
  region = var.region
}

resource "google_compute_region_backend_service" "ilb-backend" {
  project               = module.project-nginx-hello.project_id
  name                  = "${var.app_name}-${var.region}-backend"
  load_balancing_scheme = "INTERNAL_MANAGED"

  protocol = "HTTPS"

  backend {
    group           = google_compute_region_network_endpoint_group.cloudrun_neg.id
    capacity_scaler = "1.0"
    balancing_mode  = "UTILIZATION"
  }
}