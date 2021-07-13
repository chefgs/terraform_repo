variable "gcp_project_id" {
  default = "-225805"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-c"
}
variable "vm_name" {
  default = "gcp_tf_vm"
}
variable "vm_type" {
  default = "n1-standard-1"
}
variable "vm_image" {
  default = "centos-cloud/centos-7"
}
variable "vm_image_type" {
  default = "pd-standard"
}
variable "source_account_email" {
  default = "dummy_source_account_email"
}
variable "metadata_script" {
  default = "initscript_chef.sh"
}
variable "metadata_script_changed" {
  default = "true"
}
variable "creds_file" {
  default = ".keys/account.json"
}

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

resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.vm_type

  tags = ["vm", "tf"]

  boot_disk {
    initialize_params {
      image = var.vm_image
      type = var.vm_image_type
    }
  }

  network_interface {
    network = "default"
    subnetwork = "default"
  }

  metadata = {
    vm = "tf"
    metadata_script_changed = var.metadata_script_changed
  }

  metadata_startup_script = var.metadata_script

  service_account {
    email = var.source_account_email
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

