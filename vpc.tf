resource "google_compute_network" "testnet" {
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "testsub" {
  name          = var.subnetwork_name
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.testnet.id
}

resource "google_compute_firewall" "testfirewall" {
  name          = var.firewall_name
  network       = google_compute_network.testnet.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "testssh" {
  name          = var.firewall_name1
  network       = google_compute_network.testnet.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}