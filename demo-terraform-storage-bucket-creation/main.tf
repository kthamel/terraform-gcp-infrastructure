resource "google_storage_bucket" "kthamel-storage-bucket-dev" {
  name     = "kthamel-storage-dev"
  location = "us-central1"
  project  = "terraform-gcp-infrastructure"
}
