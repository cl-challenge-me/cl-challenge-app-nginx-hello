resource "google_compute_firewall" "default" {
  project     = module.project-nginx-hello.project_id
  name        = "access-ilb"
  network     = module.project-nginx-hello.network_id
  description = "Allow GFE access to ILB"

  source_ranges = [
    "130.211.0.0/22", 
    "35.191.0.0/16"
  ]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}