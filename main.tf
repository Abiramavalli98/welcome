locals {
 region    = "us-central1"
 base_cidr = "10.0.0.0/16"
}

resource "google_compute_network" "main_vpc" {
 name                    = "my-custom-vpc"
 auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
 name          = "public-subnetnew"
 network       = google_compute_network.main_vpc.id
 region        = local.region  # Generates 10.0.0.0/24
 ip_cidr_range = cidrsubnet(local.base_cidr, 8, 0)
}

resource "google_compute_subnetwork" "private_subnet" {
 name          = "private-subnetnew"
 network       = google_compute_network.main_vpc.id
 region        = local.region  # Generates 10.0.0.0/24
 ip_cidr_range = cidrsubnet(local.base_cidr, 8, 1)
}

resource "google_compute_router" "router" {
 name    = "nat-router"
 network = google_compute_network.main_vpc.id
 region  = local.region
}

resource "google_compute_router_nat" "nat" {
 name                               = "nat-gateway"
 router                             = google_compute_router.router.name
 region                             = google_compute_router.router.region
 nat_ip_allocate_option             = "AUTO_ONLY"

 source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"


 subnetwork {
   name                    = google_compute_subnetwork.private_subnet.id
   source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
 }
}
