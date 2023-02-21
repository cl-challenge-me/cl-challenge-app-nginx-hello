// Forwarding rule for VPC private service connect
# resource "google_compute_forwarding_rule" "default" {
#   provider              = google-beta
#   project               = module.project-nginx-hello.project_id

#   name                  = "psc-endpoint"
#   region                = var.region
#   load_balancing_scheme = ""
#   target                = google_compute_service_attachment.producer_service_attachment.id
#   network               = google_compute_network.consumer_net.name
#   ip_address            = google_compute_address.consumer_address.id
# }


resource "google_compute_subnetwork" "psc_producer_subnet" {
  project = module.project-nginx-hello.project_id

  name          = "psc-producer-net-${var.region}"
  ip_cidr_range = cidrsubnet(var.project_ip_cidr_range, 4, 14)
  network       = module.project-nginx-hello.network_id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

resource "google_compute_service_attachment" "producer_service_attachment" {
  project = module.project-nginx-hello.project_id

  name        = "${var.app_name}-${var.region}"
  description = "A service attachment for ${var.app_name} in ${var.region}"

  connection_preference = "ACCEPT_MANUAL"
  consumer_accept_lists {
    project_id_or_num = data.terraform_remote_state.infra.outputs.project_id
    connection_limit  = 0
  }
  nat_subnets           = [google_compute_subnetwork.psc_producer_subnet.name]
  target_service        = google_compute_forwarding_rule.ilb.id
  enable_proxy_protocol = false
}