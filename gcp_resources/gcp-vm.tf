

provider "google" {
  credentials = "${file(".keys//account.json")}"
  project     = "tensile-tenure-225805"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_instance" "default" {
  name         = "gcp-tf-vm"
  machine_type = "f1-micro"
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

  #metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = "704858967734-compute@developer.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}