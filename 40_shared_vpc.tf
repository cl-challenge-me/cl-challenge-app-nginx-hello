resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = data.terraform_remote_state.infra.outputs.project_id
  service_project = module.project-nginx-hello.project_id
}