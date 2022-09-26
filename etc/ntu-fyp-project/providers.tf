provider "google" {
  project = "ntu-fyp-project"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-ntu-fyp-project"
    prefix  = "terraform/state"
  }
}

