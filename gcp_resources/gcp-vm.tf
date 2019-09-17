variable "gcp_project_id" {
  default = "tensile-tenure-225805"
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

provider "google" {
  version = "~> 2.11"
  credentials = "${file(".keys//account.json")}"
  project     = "${var.gcp_project_id}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

resource "google_compute_instance" "default" {
  name         = "${var.vm_name}"
  machine_type = "${var.vm_type}"

  tags = ["vm", "tf"]

  boot_disk {
    initialize_params {
      image = "${var.vm_image}"
      type = "${var.vm_image_type}"
    }
  }

  // Local SSD disk
  //scratch_disk {
  // interface = "SCSI" 
  //}

  network_interface {
    network = "default"
    subnetwork = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    vm = "tf"
  }

  metadata_startup_script = "${file("${var.metadata_script}")}"

  service_account {
    email = "${var.source_account_email}"
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

