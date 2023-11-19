resource "google_container_cluster" "kthamel-gke-cluster" {
  name = "kthamel-gke-cluster"
  // location                 = "us-central1" // Multi AZ deployment configuration
  location                 = "us-central1-a" // Single AZ deployment configuration
  remove_default_node_pool = true
  initial_node_count       = 1
  project                  = "terraform-gcp-infrastructure"
  network                  = google_compute_network.kthamel-vpc-dev.id
  subnetwork               = google_compute_subnetwork.kthamel-vpc-dev-subnet-1.id
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "svcs"
  }
}

resource "google_container_node_pool" "kthamel-gke-cluster-system-nodes" {
  name       = "kthamel-gke-system-nodes"
  project    = "terraform-gcp-infrastructure"
  cluster    = google_container_cluster.kthamel-gke-cluster.id
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    disk_size_gb = 10
    labels = {
      name = "system-node"
    }
  }
}

resource "google_container_node_pool" "kthamel-gke-cluster-worker-nodes" {
  name       = "kthamel-gke-worker-nodes"
  project    = "terraform-gcp-infrastructure"
  cluster    = google_container_cluster.kthamel-gke-cluster.id
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    disk_size_gb = 10
    labels = {
      name = "worker-node"
    }
  }
}
