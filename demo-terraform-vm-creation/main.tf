resource "google_compute_instance" "kthamel-instance" {
  name         = "kthamel-demo-instance"
  project      = "terraform-gcp-infrastructure"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
  }
  labels = {
    name    = "kthamel-terraform-gcp-instance"
    project = "kthamel-terraform-gcp"
  }
}

output "self_link_value" {
  value = google_compute_instance.kthamel-instance.self_link
}
