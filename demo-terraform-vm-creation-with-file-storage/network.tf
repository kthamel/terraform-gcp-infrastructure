data "google_client_openid_userinfo" "me" {}

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
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-all" {
  name     = "kthamel-vpc-dev-firewall-all"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"] // Have to change into /32 public ip
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-icmp" {
  name     = "kthamel-vpc-dev-firewall-icmp"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 101

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] // Have to change according to internal subnets
}

resource "tls_private_key" "kthamel-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "kthamel-ssh-pem" {
  content         = tls_private_key.kthamel-ssh.private_key_pem
  filename        = "kthamel-key"
  file_permission = "0600"
}
