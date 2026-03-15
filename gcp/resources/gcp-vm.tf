terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  credentials = var.creds_file
  project     = var.gcp_project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.vm_type

  tags = ["vm", "tf", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image
      type = var.vm_image_type
    }
  }

  network_interface {
    network = "default"
    subnetwork = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    vm = "tf"
    metadata_script_changed = var.metadata_script_changed
  }

  metadata_startup_script = file(var.metadata_script)

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.source_account_email
    scopes = ["cloud-platform"]
  }
}

