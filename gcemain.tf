
resource "google_compute_network" "testnet" {
  name                    = var.network_name
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "testsub" {
  name          = var.subnetwork_name
  network       = google_compute_network.testnet.id
  region = var.region
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_instance" "test" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.testsub.id
    access_config {}
  }
}