resource "google_compute_network" "kthamel-vpc-dev" {
  name                    = "kthamel-vpc-dev"
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

resource "google_compute_subnetwork" "kthamel-vpc-dev-subnet-private" {
  name          = "kthamel-vpc-dev-subnet-private"
  ip_cidr_range = "172.17.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.id
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-ssh" {
  name     = "kthamel-vpc-dev-firewall-ssh"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["kthemel-dev"]
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-http" {
  name     = "kthamel-vpc-dev-firewall-http"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 101

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_tags = ["kthemel-dev"]
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-https" {
  name     = "kthamel-vpc-dev-firewall-https"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 102

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_tags = ["kthemel-dev"]
}
