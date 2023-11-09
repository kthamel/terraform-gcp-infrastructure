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
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_subnetwork" "kthamel-vpc-test-subnet-public" {
  name          = "kthamel-vpc-test-subnet-public"
  ip_cidr_range = "172.17.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-test.self_link
  project       = google_compute_network.kthamel-vpc-test.project
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-icmp" {
  name     = "kthamel-vpc-dev-firewall-icmp"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
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
    ports    = ["0-65535"]
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

resource "google_compute_instance" "kthamel-instance-dev" {
  name         = "kthamel-demo-instance-dev"
  project      = "terraform-gcp-infrastructure"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.kthamel-vpc-dev-subnet-public.self_link
  }
  labels = {
    name    = "kthamel-terraform-gcp-instance-dev"
    project = "kthamel-terraform-gcp"
  }
}

resource "google_compute_instance" "kthamel-instance-test" {
  name         = "kthamel-demo-instance-test"
  project      = "terraform-gcp-infrastructure"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.kthamel-vpc-test-subnet-public.self_link
  }
  labels = {
    name    = "kthamel-terraform-gcp-instance-test"
    project = "kthamel-terraform-gcp"
  }
}
