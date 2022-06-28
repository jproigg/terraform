terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}


provider "google" {

    credentials = file(var.credentials_file)
    project = var.project
    region  = var.region
    zone    = var.zone
  
}


resource "google_project_service" "api" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com"
  ])
  disable_on_destroy = false
  service            = each.value
}

resource "google_compute_firewall" "web" {
  name          = "web-access"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_instance" "apache-server" {
  name         = "apache-server"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default" 
    access_config {}    
  }
  
  metadata_startup_script = file(var.apache)

  depends_on = [google_project_service.api, google_compute_firewall.web]
}


