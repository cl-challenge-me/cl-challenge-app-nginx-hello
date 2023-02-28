resource "google_compute_subnetwork" "psc_producer_subnet" {
  for_each = toset(var.regions)
  project  = module.project.project_id
  region   = each.key

  name          = "psc-producer-net-${each.key}"
  ip_cidr_range = cidrsubnet(var.vm_ip_cidr_range, 4, 4 + index(var.regions, each.key))
  network       = module.project.network_id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

resource "google_compute_service_attachment" "producer_service_attachment" {
  for_each = toset(var.regions)
  project  = module.project.project_id
  region   = each.key

  name        = "${var.app_name}-${each.key}"
  description = "A service attachment for ${var.app_name} in ${each.key}"

  connection_preference = "ACCEPT_MANUAL"
  consumer_accept_lists {
    project_id_or_num = data.terraform_remote_state.infra.outputs.project_id
    connection_limit  = 10
  }
  nat_subnets           = [google_compute_subnetwork.psc_producer_subnet[each.key].name]
  target_service        = module.ilb[each.key].forwarding_rule_id
  enable_proxy_protocol = false
}