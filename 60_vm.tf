resource "random_id" "vm" {
  byte_length = 2
}

data "google_compute_zones" "available" {
  for_each = toset(var.regions)
  project  = module.project.project_id
  region   = each.key

  depends_on = [
    module.project
  ]
}

# Compute instance helper VM
resource "google_compute_instance" "magic-vm" {
  for_each     = toset(var.regions)
  project      = module.project.project_id
  name         = "magic-vm-${var.env}-${random_id.vm.dec}"
  machine_type = "f1-micro"
  zone         = data.google_compute_zones.available[each.key].names[2]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = module.project.network_id
    subnetwork = module.project.subnets[each.key].id
  }
}