resource "google_container_cluster" "kthamel-gke-cluster" {
  name                     = "kthamel-gke-cluster"
  location                 = "us-central1"
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

resource "google_container_node_pool" "kthamel-gke-cluster-nodes" {
  name       = "kthamel-gke-nodes"
  project    = "terraform-gcp-infrastructure"
  cluster    = google_container_cluster.kthamel-gke-cluster.id
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    disk_size_gb = 20
  }
}
