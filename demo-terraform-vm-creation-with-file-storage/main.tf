resource "google_filestore_instance" "kthamel-nfs-instance" {
  name     = "kthamelnfs"
  project  = "terraform-gcp-infrastructure"
  location = "us-central1-a"
  tier     = "STANDARD"

  file_shares {
    capacity_gb = 1024
    name        = "kthamelnfs"
    nfs_export_options {
      ip_ranges   = ["172.16.0.0/29"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }

  networks {
    network           = google_compute_network.kthamel-vpc-dev.name
    modes             = ["MODE_IPV4"]
    reserved_ip_range = "172.18.0.0/29"
  }
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
    access_config {}
  }

  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.kthamel-ssh.public_key_openssh}"
  }

  labels = {
    name    = "kthamel-terraform-gcp-instance-dev"
    project = "kthamel-terraform-gcp"
  }
}

resource "google_kms_key_ring" "kthamel-nfs-keyring" {
  name     = "kthamel-nfs-keyring"
  location = "global"
  project  = "terraform-gcp-infrastructure"
}

resource "google_kms_crypto_key" "kthamel-nfs-crypto-key" {
  name     = "kthamel-nfs-crypto-key"
  key_ring = google_kms_key_ring.kthamel-nfs-keyring.id
}
