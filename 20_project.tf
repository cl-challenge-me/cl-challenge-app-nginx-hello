locals {
  services = [
    "compute.googleapis.com",
    "run.googleapis.com"
  ]
}

module "project-nginx-hello" {
  source          = "git::ssh://git@github.com/cl-challenge-me/cl-challenge-base-project.git?ref=v1.5"
  name            = "${var.app_name}-${var.env}"
  folder_id       = var.folder_id
  services        = local.services
  billing_account = var.billing_account
  region          = var.region
  ip_cidr_range   = cidrsubnet(var.project_ip_cidr_range, 4, 0)
}