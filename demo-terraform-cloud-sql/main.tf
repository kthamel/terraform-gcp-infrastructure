resource "google_sql_database_instance" "kthamel-sql-instance" {
  name             = "kthamel-sql-instance"
  region           = "us-central1"
  project          = "terraform-gcp-infrastructure"
  database_version = "POSTGRES_14"
  root_password    = random_string.kthamel-string-1.id
  settings {
    tier = "db-f1-micro"
  }
  deletion_protection = "false"
}

resource "random_string" "kthamel-string-1" {
  length  = 10
  lower   = true
  upper   = true
  special = false
  numeric = true
}

resource "google_sql_user" "kthamel-sql" {
  name     = "kthamel-sql"
  project  = "terraform-gcp-infrastructure"
  instance = google_sql_database_instance.kthamel-sql-instance.name
  password = random_string.kthamel-string-1.id
}

output "kthamel-sql-db-password" {
  description = "sql-db-passwd"
  value       = random_string.kthamel-string-1.id
}
