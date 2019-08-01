
provider "google" {
  version = "~> 2.11"
  credentials = "${file(".keys//account.json")}"
  project     = "tensile-tenure-225805"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_instance" "default" {
  name         = "gcp-tf-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["vm", "tf"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      type = "pd-standard"
    }
  }

  // Local SSD disk
  scratch_disk {
   interface = "SCSI" 
  }

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

  #metadata_startup_script = "initscript.sh"
  metadata_startup_script = "${file("initscript.sh")}"

  service_account {
    email = "704858967734-compute@developer.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

