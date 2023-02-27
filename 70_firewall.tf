resource "google_compute_firewall" "default" {
  project     = module.project.project_id
  name        = "access-iap"
  network     = module.project.network_id
  description = "Allow IAM access to VMs"

  source_ranges = [
    "35.235.240.0/20"
  ]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}