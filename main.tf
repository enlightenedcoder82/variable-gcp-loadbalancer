terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "us-central1a-subnet" {
  name                     = var.subnet_name
  network                  = google_compute_network.vpc.self_link
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_instance_template" "instance-template" {
  name        = var.instance-template
  description = "romulus-server"
  labels = {
    environment = "production"
    name        = "romulus-server"
  }
  instance_description = "this is an instance that has been autochaled"
  machine_type         = "e2-medium"
  can_ip_forward       = "false"

  scheduling {
    automatic_restart   = "true"
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = "true"
    boot         = "true"
  }
  disk {

    auto_delete  = "false"
    disk_size_gb = 10
    mode         = "READ_WRITE"
    type         = "PERSISTENT"

  }
  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.us-central1a-subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }

  tags = ["http-server"]


  metadata_startup_script = file("startup.sh")

}

resource "google_compute_health_check" "health-check05" {
  count               = 1
  name                = var.health-check01
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_region_instance_group_manager" "region-instance-group" {
  name = var.region-instance-group
  base_instance_name        = "app"
  region                    = var.region
  distribution_policy_zones = ["us-central1-a","us-central1-b", "us-central1-c","us-central1-f"]

  version {
    instance_template = google_compute_instance_template.instance-template.id
  }

  named_port {
    name = "custom"
    port = 80
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  # count = 1 
  name    = var.autoscaler
  project = var.project
  region  = var.region
  target  = google_compute_region_instance_group_manager.region-instance-group.self_link

  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 3
    cooldown_period = 60
    cpu_utilization {
      target = 0.6
    }
  }
}

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
resource "google_compute_firewall" "allow-icmp" {
  name    = var.firewall-1
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
  priority      = 600
}

resource "google_compute_firewall" "http" {
  name    = var.firewall-2
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  priority      = 100
}

resource "google_compute_firewall" "https" {
  name    = var.firewall-3
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
  priority      = 100
}

resource "google_compute_firewall" "fw1" {
  provider      = google
  name          = var.firewall-4
  network       = google_compute_network.vpc.id
  source_ranges = ["10.1.2.0/24"]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
}

resource "google_compute_firewall" "fw2" {
  provider      = google
  name          = var.firewall-5
  network       = google_compute_network.vpc.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["allow-ssh"]
  direction   = "INGRESS"
}

resource "google_compute_firewall" "fw3" {
  provider      = google
  name          = var.firewall-6
  network       = google_compute_network.vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["load-balanced-backend"]
  direction   = "INGRESS"
}

resource "google_compute_firewall" "fw4" {
  provider      = google
  name          = var.firewall-7
  network       = google_compute_network.vpc.id
  source_ranges = ["10.129.0.0/26"]
  target_tags   = ["load-balanced-backend"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
  direction = "INGRESS"
}

