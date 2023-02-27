resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  for_each              = toset(var.regions)
  project               = module.project.project_id
  name                  = "${var.app_name}-neg-${each.key}"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.nginx-hello[each.key].name
  }
  region = each.key
}

resource "google_compute_global_address" "lb-fe-ip" {
  provider   = google-beta
  project    = module.project.project_id
  name       = "l7-lb-fe-ip"
  ip_version = "IPV4"
}

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "7.0.0"

  project        = module.project.project_id
  name           = "global-l7-lb"
  ssl            = true
  https_redirect = true

  create_address = false
  address        = google_compute_global_address.lb-fe-ip.address

  managed_ssl_certificate_domains = [module.cloud-ep-dns.endpoint]

  load_balancing_scheme = "EXTERNAL_MANAGED"

  firewall_networks = []

  backends = {
    default = {
      description             = null
      port                    = "443"
      protocol                = "HTTPS"
      timeout_sec             = null
      port_name               = null
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = module.cloud_armor.policy.id
      compression_mode        = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = null

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        for neg in google_compute_region_network_endpoint_group.cloudrun_neg :
        {
          # Each node pool instance group should be added to the backend.
          group                        = neg.id
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
          health_check                 = null
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}