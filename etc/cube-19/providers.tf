provider "google" {
  project = "cube-19"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-19"
    prefix  = "terraform/state"
  }
}

