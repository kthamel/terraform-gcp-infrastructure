resource "google_compute_global_address" "kthamel-dev-global-address" {
  name    = "kthamel-dev-global-address"
  project = google_compute_network.kthamel-vpc-dev.project
}

resource "google_compute_global_forwarding_rule" "kthamel-dev-forwarding-http" {
  name    = "kthamel-dev-forwarding-http"
  project = google_compute_network.kthamel-vpc-dev.project
  target  = google_compute_instance_group_manager.kthamel-dev-instance-group-manager.self_link
  network = google_compute_network.kthamel-vpc-dev.name
}

resource "google_compute_backend_service" "kthamel-dev-backend-service" {
  name                  = "kthamel-dev-backend-service"
  project               = google_compute_network.kthamel-vpc-dev.project
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_checks = [google_compute_http_health_check.kthamel-dev-http-health-check.id]
}

resource "google_compute_http_health_check" "kthamel-dev-http-health-check" {
  project            = google_compute_network.kthamel-vpc-dev.project
  name               = "kthamel-dev-http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_url_map" "kthamel-dev-url-map" {
  name            = "kthamel-dev-url-map"
  project         = google_compute_network.kthamel-vpc-dev.project
  default_service = google_compute_backend_service.kthamel-dev-backend-service.id

  host_rule {
    hosts        = ["kthamel-gcp-dev.localx"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.kthamel-dev-backend-service.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.kthamel-dev-backend-service.id
    }
  }
}

resource "google_compute_target_http_proxy" "kthamel-dev-http-proxy" {
  name                        = "kthamel-dev-http-proxy"
  project                     = google_compute_network.kthamel-vpc-dev.project
  url_map                     = google_compute_url_map.kthamel-dev-url-map.id
  http_keep_alive_timeout_sec = 610
}

resource "google_dns_managed_zone" "kthamel-vpc-dns-zone" {
  name        = "kthamel-dns-zone"
  dns_name    = "kthamel-gcp-dev.localx."
  description = "Testing Purpose"
  project     = google_compute_network.kthamel-vpc-dev.project

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.kthamel-vpc-dev.id
    }
  }
}

resource "google_dns_record_set" "kthamel-dev-dns" {
  name         = "dev-1.kthamel-gcp-dev.localx."
  managed_zone = google_dns_managed_zone.kthamel-vpc-dns-zone.name
  project      = google_dns_managed_zone.kthamel-vpc-dns-zone.project
  type         = "A"
  ttl          = 300
  routing_policy {
    wrr {
      weight  = 0.8
      rrdatas = ["dev-1.kthamel-gcp-dev.localx."]
    }

    wrr {
      weight  = 0.2
      rrdatas = ["dev-1.kthamel-gcp-dev.localx."]
    }
  }
}
