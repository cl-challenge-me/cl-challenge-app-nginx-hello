locals {
  services = [
    "compute.googleapis.com",
    "run.googleapis.com"
  ]
}

module "project" {
  source = "github.com/cl-challenge-me/cl-challenge-base-project?ref=v1.6"
  name            = "${var.app_name}-${var.env}"
  folder_id       = var.folder_id
  services        = local.services
  billing_account = var.billing_account
  regions         = var.regions
  ip_cidr_ranges = [
    cidrsubnet(var.vm_ip_cidr_range, 4, 0),
    cidrsubnet(var.vm_ip_cidr_range, 4, 1)
  ]
}