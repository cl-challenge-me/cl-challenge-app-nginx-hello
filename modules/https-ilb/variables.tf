variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "proxy_ip_cidr_range" {
  description = "IP range used for proxy-only subnet"
  type        = string
}

variable "backend_group_id" {
  description = "LB backend group ID"
  type        = string
}