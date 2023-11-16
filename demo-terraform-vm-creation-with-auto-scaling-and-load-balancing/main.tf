data "google_client_openid_userinfo" "me" {}

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

resource "google_compute_router" "kthamel-vpc-dev-cloud-router" {
  project = google_compute_network.kthamel-vpc-dev.project
  name    = "kthamel-vpc-dev-cloud-router"
  network = google_compute_network.kthamel-vpc-dev.name
  region  = google_compute_subnetwork.kthamel-vpc-dev-subnet-public.region
}

resource "google_compute_router_nat" "kthamel-vpc-dev-nat-gw" {
  name                               = "kthamel-vpc-dev-nat-gw"
  router                             = google_compute_router.kthamel-vpc-dev-cloud-router.name
  region                             = google_compute_subnetwork.kthamel-vpc-dev-subnet-public.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = google_compute_network.kthamel-vpc-dev.project

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-all" {
  name     = "kthamel-vpc-dev-firewall-all"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["80"]
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

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kthamel-vpc-test-firewall-all" {
  name     = "kthamel-vpc-test-firewall-all"
  network  = google_compute_network.kthamel-vpc-test.name
  project  = google_compute_network.kthamel-vpc-test.project
  priority = 100

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] // Have to change into /32 public ip
}

resource "google_compute_firewall" "kthamel-vpc-test-firewall-icmp" {
  name     = "kthamel-vpc-test-firewall-icmp"
  network  = google_compute_network.kthamel-vpc-test.name
  project  = google_compute_network.kthamel-vpc-test.project
  priority = 101

  allow {
    protocol = "icmp"
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

resource "tls_private_key" "kthamel-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "kthamel-ssh-pem" {
  content         = tls_private_key.kthamel-ssh.private_key_pem
  filename        = "kthamel-key"
  file_permission = "0600"
}
