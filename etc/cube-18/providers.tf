provider "google" {
  project = "cube-18"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-18"
    prefix  = "terraform/state"
  }
}

