variable "instance_name" {
  default = "first-vm"
}

variable "machine_type" {
  default = "e2-medium"
}

variable "zone" {
  default = "us-central1-a"
}

variable "region" {
  default = "us-central1"
}

variable "image_name" {
  default = "debian-cloud/debian-12"
}

variable "network_name" {
  default = "network1"
}

variable "subnetwork_name" {
  default = "subnet1"
}