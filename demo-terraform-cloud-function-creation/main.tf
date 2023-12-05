resource "google_storage_bucket" "kthamel-storage-bucket-dev" {
  name     = "kthamel-storage-dev"
  location = "us-central1"
  project  = "terraform-gcp-infrastructure"
}

resource "google_storage_bucket_object" "kthamel-storage-object" {
  name   = "code.zip"
  bucket = google_storage_bucket.kthamel-storage-bucket-dev.name
  source = "./code.zip"
}

resource "google_cloudfunctions_function" "kthamel-dev-function" {
  name                  = "kthamel-dev-function"
  region                = "us-central1"
  project               = "terraform-gcp-infrastructure"
  runtime               = "nodejs18"
  available_memory_mb   = "256"
  trigger_http          = true
  source_archive_bucket = google_storage_bucket.kthamel-storage-bucket-dev.name
  source_archive_object = google_storage_bucket_object.kthamel-storage-object.name
}

output "cloud-function-url" {
  value = google_cloudfunctions_function.kthamel-dev-function.https_trigger_url
}
