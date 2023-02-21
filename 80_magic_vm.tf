data "google_compute_zones" "available" {
  project = module.project-nginx-hello.project_id
}

# Compute instance helper VM
resource "google_compute_instance" "magic-vm" {
  project      = module.project-nginx-hello.project_id
  name         = "magic-vm-${var.env}"
  machine_type = "f1-micro"
  zone         = data.google_compute_zones.available.names[2]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = module.project-nginx-hello.network_id
    subnetwork = module.project-nginx-hello.subnet_id
  }
}