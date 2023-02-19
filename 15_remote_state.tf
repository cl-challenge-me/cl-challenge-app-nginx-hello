data "terraform_remote_state" "infra" {
  backend = "gcs"

  config = {
    bucket = "cl-challenge-${var.env}"
    prefix = "cl-challenge-infra"
  }
}
