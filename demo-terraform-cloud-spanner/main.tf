resource "google_spanner_instance" "kthamel-spanner-instance" {
  name             = "kthamel-spanner-instance"
  config           = "regional-us-central1"
  display_name     = "kthamel-spanner-instance"
#   num_nodes        = 2  //num_nodes or processing_units//
  processing_units = 100
  labels = {
    "project" = "dev"
  }
  project       = "terraform-gcp-infrastructure"
  force_destroy = true
}
