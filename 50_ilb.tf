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


module "ilb" {
  for_each            = toset(var.regions)
  source              = "./modules/https-ilb"
  project_id          = module.project.project_id
  app_name            = var.app_name
  region              = each.key
  network_id          = module.project.network_id
  subnet_id           = module.project.subnets[each.key].id
  proxy_ip_cidr_range = cidrsubnet(var.proxy_ip_cidr_range, 2, index(var.regions, each.key))
  backend_group_id    = google_compute_region_network_endpoint_group.cloudrun_neg[each.key].id
}