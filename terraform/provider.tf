provider "google" {
  project = "dv-kube-hw"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

terraform {
 backend "gcs" {
   bucket  = "dv-terra-admin"
   prefix  = "state/"
   project = "dv-kube-hw"
 }
}
