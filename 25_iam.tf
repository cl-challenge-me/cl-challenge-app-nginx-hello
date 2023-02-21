resource "google_service_account" "cloudrun_sa" {
  project = module.project-nginx-hello.project_id
  account_id = "${var.app_name}-cloud-run-sa"
  display_name = "Service account for Cloud Run ${var.app_name} service"
}

resource "google_service_account" "vm_sa" {
  project = module.project-nginx-hello.project_id
  account_id = "${var.app_name}-vm-sa"
  display_name = "Service account for Compute Engine VMs"
}