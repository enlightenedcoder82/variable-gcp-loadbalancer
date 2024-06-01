

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







