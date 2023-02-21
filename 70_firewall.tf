resource "google_compute_firewall" "default" {
  project     = module.project-nginx-hello.project_id
  name        = "access-iap"
  network     = module.project-nginx-hello.network_id
  description = "Allow IAM access to VMs"

  source_ranges = [
    "35.235.240.0/20"
  ]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}