resource "google_storage_bucket" "kthamel-storage-bucket-dev" {
  name                     = "kthamel-storage-dev"
  location                 = "us-central1"
  project                  = "terraform-gcp-infrastructure"
  public_access_prevention = "enforced"
  # public_access_prevention = "inherited"
  force_destroy            = true
  storage_class            = "STANDARD"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_object" "kthamel-storage-object" {
  name   = "codes"
  bucket = google_storage_bucket.kthamel-storage-bucket-dev.name
  source = "code.txt"
}

output "kthamel-bucket-url" {
  value = google_storage_bucket.kthamel-storage-bucket-dev.self_link
}
