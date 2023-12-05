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
  name                  = "hello-world"
  region                = "us-central1"
  project               = "terraform-gcp-infrastructure"
  runtime               = "nodejs20"
  available_memory_mb   = "256"
  trigger_http          = true
  entry_point           = "helloHttp"
  source_archive_bucket = google_storage_bucket.kthamel-storage-bucket-dev.name
  source_archive_object = google_storage_bucket_object.kthamel-storage-object.name
  ingress_settings      = "ALLOW_ALL"
  min_instances         = 1
  max_instances         = 3
}

resource "google_cloudfunctions_function_iam_member" "dev-function-invoker" {
  project        = google_cloudfunctions_function.kthamel-dev-function.project
  cloud_function = google_cloudfunctions_function.kthamel-dev-function.name
  region         = "us-central1"
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

output "cloud-function-url" {
  value = google_cloudfunctions_function.kthamel-dev-function.https_trigger_url
}
