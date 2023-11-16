resource "google_compute_instance_template" "kthamel-dev-template" {
  name           = "kthamel-dev-template"
  project        = google_compute_network.kthamel-vpc-dev.project
  machine_type   = "e2-micro"
  can_ip_forward = "false"
  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.kthamel-ssh.public_key_openssh}"
  }

  metadata_startup_script = <<-USERDATA
    #!/bin/bash
    sudo apt-get update -y
    sudo apt install apache2 -y
    cd /var/www/html/
    hostname > index.html
  USERDATA

  disk {
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.kthamel-vpc-dev-subnet-public.self_link
  }
}

resource "google_compute_instance_group_manager" "kthamel-dev-instance-group-manager" {
  name               = "kthamel-dev-instance-group-manager"
  project            = google_compute_network.kthamel-vpc-dev.project
  base_instance_name = "kthamel-dev-vm"
  zone               = "us-central1-a"

  version {
    name              = "version-dev"
    instance_template = google_compute_instance_template.kthamel-dev-template.self_link
  }
}

resource "google_compute_autoscaler" "kthamel-dev-asg" {
  name    = "kthamel-dev-asg"
  project = google_compute_network.kthamel-vpc-dev.project
  zone    = "us-central1-a"
  target  = google_compute_instance_group_manager.kthamel-dev-instance-group-manager.self_link

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 2
    cooldown_period = 60
  }
}
