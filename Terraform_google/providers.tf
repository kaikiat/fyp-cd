provider "google" {
  project = "cube-17"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-17"
    prefix  = "terraform/state"
  }
}

