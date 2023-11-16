resource "google_compute_network" "kthamel-vpc-dev" {
  name                    = "kthamel-vpc-dev"
  project                 = "terraform-gcp-infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_subnetwork" "kthamel-vpc-dev-subnet-1" {
  name          = "kthamel-vpc-dev-subnet-1"
  ip_cidr_range = "172.16.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_subnetwork" "kthamel-vpc-test-subnet-2" {
  name          = "kthamel-vpc-dev-subnet-2"
  ip_cidr_range = "172.17.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_subnetwork" "kthamel-vpc-dev-subnet-3" {
  name          = "kthamel-vpc-dev-subnet-3"
  ip_cidr_range = "172.18.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_subnetwork" "kthamel-vpc-test-subnet-4" {
  name          = "kthamel-vpc-dev-subnet-4"
  ip_cidr_range = "172.19.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-tcp-all" {
  name     = "kthamel-vpc-dev-firewall-all"
  network  = google_compute_network.kthamel-vpc-dev.self_link
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-icmp" {
  name     = "kthamel-vpc-dev-firewall-icmp"
  network  = google_compute_network.kthamel-vpc-dev.self_link
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 101

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
