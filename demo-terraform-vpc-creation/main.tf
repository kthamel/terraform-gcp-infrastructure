resource "google_compute_network" "kthamel-vpc-dev" {
  name                    = "kthamel-vpc-dev"
  project                 = "terraform-gcp-infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_subnetwork" "kthamel-vpc-dev-subnet-1" {
  name          = "kthamel-vpc-dev-us-west1"
  ip_cidr_range = "172.16.0.0/20"
  region        = "us-west1"
  network       = google_compute_network.kthamel-vpc-dev.id
  project       = google_compute_network.kthamel-vpc-dev.project
}
