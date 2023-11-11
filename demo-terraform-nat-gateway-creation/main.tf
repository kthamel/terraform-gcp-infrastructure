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

resource "google_compute_subnetwork" "kthamel-vpc-dev-subnet-private" {
  name          = "kthamel-vpc-dev-subnet-private"
  ip_cidr_range = "172.17.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kthamel-vpc-dev.self_link
  project       = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_firewall" "kthamel-vpc-dev-firewall-ssh" {
  name     = "kthamel-vpc-dev-firewall-ssh"
  network  = google_compute_network.kthamel-vpc-dev.name
  project  = google_compute_network.kthamel-vpc-dev.project
  priority = 101

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "kthamel-vpc-dev-cloud-router" {
  project = google_compute_network.kthamel-vpc-dev.project
  name    = "kthamel-vpc-dev-cloud-router"
  network = google_compute_network.kthamel-vpc-dev.name
  region  = google_compute_subnetwork.kthamel-vpc-dev-subnet-private.region
}

resource "google_compute_router_nat" "kthamel-vpc-dev-nat-gw" {
  name                               = "kthamel-vpc-dev-nat-gw"
  router                             = google_compute_router.kthamel-vpc-dev-cloud-router.name
  region                             = google_compute_subnetwork.kthamel-vpc-dev-subnet-private.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = google_compute_network.kthamel-vpc-dev.project

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
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
    subnetwork = google_compute_subnetwork.kthamel-vpc-dev-subnet-private.self_link
  }

  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.kthamel-ssh.public_key_openssh}"
  }

  labels = {
    name    = "kthamel-terraform-gcp-instance-dev"
    project = "kthamel-terraform-gcp"
  }
}
