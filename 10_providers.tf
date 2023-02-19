terraform {
  backend "gcs" {
    prefix = "cl-challenge-app-nginx-hello"
  }
  required_providers {
    google      = "=4.52.0"
    google-beta = "=4.52.0"
  }
}

provider "google" {

}