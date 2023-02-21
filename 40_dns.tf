module "cloud-ep-dns" {
  source      = "terraform-google-modules/endpoints-dns/google"
  project     = module.project-nginx-hello.project_id
  name        = var.app_name
  external_ip = google_compute_global_address.lb-fe-ip.address
}