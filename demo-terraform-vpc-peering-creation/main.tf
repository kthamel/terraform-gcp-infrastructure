resource "google_compute_network" "kthamel-vpc-dev" {
  name                    = "kthamel-vpc-dev"
  project                 = "terraform-gcp-infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_network" "kthamel-vpc-test" {
  name                    = "kthamel-vpc-test"
  project                 = "terraform-gcp-infrastructure"
  auto_create_subnetworks = false
  mtu                     = 1600
}

resource "google_compute_subnetwork" "kthamel-vpc-dev-subnet-public" {
  name          = "kthamel-vpc-dev-subnet-public"
  ip_cidr_range = "172.16.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.id
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_subnetwork" "kthamel-vpc-test-subnet-public" {
  name          = "kthamel-vpc-test-subnet-public"
  ip_cidr_range = "172.17.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-test.id
  project       = google_compute_network.kthamel-vpc-test.project
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-icmp" {
  name     = "kthamel-vpc-dev-firewall-icmp"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kthamel-vpc-test-firewall-icmp" {
  name     = "kthamel-vpc-test-firewall-icmp"
  network  = google_compute_network.kthamel-vpc-test.name
  project  = google_compute_network.kthamel-vpc-test.project
  priority = 100

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_network_peering" "kthamel-vpc-dev-peering" {
  name         = "kthamel-vpc-dev-peering"
  network      = google_compute_network.kthamel-vpc-dev.self_link
  peer_network = google_compute_network.kthamel-vpc-test.self_link
}

resource "google_compute_network_peering" "kthamel-vpc-test-peering" {
  name         = "kthamel-vpc-test-peering"
  network      = google_compute_network.kthamel-vpc-test.self_link
  peer_network = google_compute_network.kthamel-vpc-dev.self_link
}
