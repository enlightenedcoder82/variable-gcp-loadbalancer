#Load Balancer

resource "google_compute_forwarding_rule" "load-balancer82" {
  provider              = google
  depends_on            = [google_compute_region_target_http_proxy.proxy-sub01, google_compute_subnetwork.proxy]
  name                  = var.loadbalancer
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.proxy-sub01.id
  network               = google_compute_network.vpc.id
  ip_address            = google_compute_address.loadbalancer-ip.address
  network_tier          = "STANDARD"
}

resource "google_compute_address" "loadbalancer-ip" {
  name         = var.loadbalancer-ip
  provider     = google
  region       = var.region
  network_tier = "STANDARD"
}

resource "google_compute_region_target_http_proxy" "proxy-sub01" {
  provider = google
  region   = var.region
  name     = var.proxy-sub01
  url_map  = google_compute_region_url_map.loadbalancer-url.id
}

resource "google_compute_subnetwork" "proxy" {
  provider      = google
  name          = var.proxy
  ip_cidr_range = "10.129.0.0/26"
  region        = var.region
  network       = google_compute_network.vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_region_url_map" "loadbalancer-url" {
  provider        = google
  region          = var.region
  name            = var.loadbalancer
  default_service = google_compute_region_backend_service.loadbalancer-backend.id
}

resource "google_compute_region_backend_service" "loadbalancer-backend" {
  provider              = google
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = google_compute_region_instance_group_manager.region-instance-group.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  region        = var.region
  name          = "website-backend"
  protocol      = "HTTP"
  timeout_sec   = 10
  health_checks = [google_compute_region_health_check.region-health-check06.id]
}

data "google_compute_image" "debian_image" {
  provider = google
  family   = "debian-12"
  project  = "debian-cloud"
}

resource "google_compute_region_health_check" "region-health-check06" {
  provider = google
  region   = var.region
  name     = var.health-check02
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}