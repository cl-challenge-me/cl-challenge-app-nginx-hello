resource "google_compute_network_peering" "to-networking-hub" {
  name         = "to-networking-hub"
  network      = module.project-nginx-hello.network_id
  peer_network = data.terraform_remote_state.infra.outputs.network_id
}

resource "google_compute_network_peering" "to-app" {
  name         = "to-app-nginx-hello"
  network      = data.terraform_remote_state.infra.outputs.network_id
  peer_network = module.project-nginx-hello.network_id
}