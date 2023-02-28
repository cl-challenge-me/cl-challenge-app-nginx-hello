# proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  project = var.project_id
  region  = var.region

  name          = "${var.app_name}-l7-ilb-proxy-subnet-${var.region}"
  ip_cidr_range = var.proxy_ip_cidr_range
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = var.network_id
}

# forwarding rule
resource "google_compute_forwarding_rule" "ilb" {
  project = var.project_id
  region  = var.region

  name                  = "${var.app_name}-l7-ilb-${var.region}"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.default.id
  network               = var.network_id
  subnetwork            = var.subnet_id
  network_tier          = "PREMIUM"
  allow_global_access   = true
}

# HTTP target proxy
resource "google_compute_region_target_https_proxy" "default" {
  project = var.project_id
  region  = var.region

  name             = "${var.app_name}-lb-https-proxy-${var.region}"
  url_map          = google_compute_region_url_map.default.id
  ssl_certificates = [google_compute_region_ssl_certificate.ilb.id]
  depends_on = [
    google_compute_subnetwork.proxy_subnet
  ]
}

resource "google_compute_region_url_map" "default" {
  project = var.project_id
  region  = var.region

  name            = "${var.app_name}-lb-url-map-${var.region}"
  default_service = google_compute_region_backend_service.ilb-backend.id
}

resource "google_compute_region_backend_service" "ilb-backend" {
  project               = var.project_id
  region  = var.region
  name                  = "${var.app_name}-${var.region}-backend"
  load_balancing_scheme = "INTERNAL_MANAGED"

  protocol = "HTTPS"

  backend {
    group           = var.backend_group_id
    capacity_scaler = "1.0"
    balancing_mode  = "UTILIZATION"
  }
}

