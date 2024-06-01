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