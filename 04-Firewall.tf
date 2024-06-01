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

