resource "random_id" "cert" {
  byte_length = 2
  keepers = {
    id = tls_self_signed_cert.default.cert_pem
  }
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  validity_period_hours = 2400

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 24

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["${var.app_name}.${var.region}.ilb"]

  subject {
    common_name  = "${var.app_name}.${var.region}.ilb"
    organization = "${var.app_name}.${var.region}.ilb"
  }
}

resource "google_compute_region_ssl_certificate" "ilb" {
  project = var.project_id
  region = var.region

  name        = "${var.app_name}-ilb-cert-${random_id.cert.dec}"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
}