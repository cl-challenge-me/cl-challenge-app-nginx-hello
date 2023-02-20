variable "region" {
  description = "Region to deploy infrastructure and applications"
  type        = string
}

variable "env" {
  description = "Short environment name (dev, stage, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "folder_id" {
  description = "Parent folder ID"
  type        = string
}

variable "billing_account" {
  description = "Billing account ID"
  type        = string
}

variable "ip_cidr_range" {
  description = "Project main network IP range"
  type        = string
}