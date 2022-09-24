provider "google" {
  project = "ntu-16"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}

terraform {
  backend "gcs" {
    # bucket  = "tf-state-prod-16"
    bucket  = "ntu-16"
    prefix  = "terraform/state"
  }
}

