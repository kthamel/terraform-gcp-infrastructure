resource "google_compute_disk" "kthamel-instance-disk" {
  name    = "kthamel-instance-disk"
  type    = "pd-standard"
  size    = 10
  zone    = google_compute_instance.kthamel-instance.zone
  project = google_compute_instance.kthamel-instance.project
  lifecycle {
    prevent_destroy = false
  }
  guest_os_features {
    type = "SECURE_BOOT"
  }
  guest_os_features {
    type = "MULTI_IP_SUBNET"
  }
  guest_os_features {
    type = "SEV_CAPABLE"
  }
  guest_os_features {
    type = "UEFI_COMPATIBLE"
  }
  guest_os_features {
    type = "VIRTIO_SCSI_MULTIQUEUE"
  }
  guest_os_features {
    type = "GVNIC"
  }
  guest_os_features {
    type = "SEV_LIVE_MIGRATABLE"
  }
  guest_os_features {
    type = "SEV_SNP_CAPABLE"
  }
  guest_os_features {
    type = "SUSPEND_RESUME_COMPATIBLE"
  }
  guest_os_features {
    type = "TDX_CAPABLE"
  }
  labels = {
    name    = "kthamel-terraform-gcp-instance"
    project = "kthamel-terraform-gcp"
  }
}

resource "google_compute_attached_disk" "google_compute_attached_disk" {
  disk     = google_compute_disk.kthamel-instance-disk.id
  instance = google_compute_instance.kthamel-instance.id
  project  = google_compute_instance.kthamel-instance.project
  zone     = google_compute_instance.kthamel-instance.zone
}

resource "google_compute_instance" "kthamel-instance" {
  name                    = "kthamel-dev-instance"
  project                 = "terraform-gcp-infrastructure"
  machine_type            = "e2-micro"
  zone                    = "us-central1-a"
  metadata_startup_script = <<-USERDATA
    #!/bin/bash
    sudo sleep 120
    sudo mkfs.ext4 -F /dev/sdb
    sudo mkdir /mnt/datax
    sudo mount /dev/sdb /mnt/datax
    BLK_ID=$(sudo blkid /dev/sdb | cut -f2 -d" ")
    echo "$BLK_ID     /mnt/datax   ext4    defaults   0   2" | sudo tee --append /etc/fstab
    sudo mount -a
    cd /mnt/datax
    sudo hostname > test.txt
  USERDATA

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
