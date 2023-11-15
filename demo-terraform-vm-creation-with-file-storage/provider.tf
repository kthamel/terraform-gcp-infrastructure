terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}