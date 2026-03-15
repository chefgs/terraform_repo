## Google Cloud Computing Engine creation using Terraform

## Objective
- Terraform example of creating an immutable instance on Google Cloud
- POC demonstrating the capability of executing the installation and configuring the Google instance using Chef cookbook
- We are utilizing the Google cloud `metadata script` feature to invoke the installation of `chef-client` and performing the cookbook automation
- GCE instance will be having below configurations set when the instances creation is completed 
  - Install Apache Server
  - Create directory and file in the path `\tmp`
  - Create user `bob` under `chefusers` group

## Important Pre-Requisites
1. Create a project in the Google Cloud Console and set up billing on that project. 
2. Adding credential
    - A. In order to make requests against the GCP API, you need to authenticate to prove that it's you making the request. The preferred method of provisioning resources with Terraform is to use a [GCP service account](https://cloud.google.com/docs/authentication/getting-started), a "robot account" that can be granted a limited set of IAM permissions.
    - B. From the [service account key page](https://console.cloud.google.com/apis/credentials/serviceaccountkey) in the Cloud Console choose an existing account, or create a new one. Next, download the JSON key file. Name it something you can remember, and store it somewhere secure on your machine.

3. Refer Google Cloud documentation on creating [Service account here](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account)

## Install and Configure Terraform
- Refer here [for installing terraform](https://www.terraform.io/downloads.html)
- Download and extract the terraform executable
- Add terraform executable path to ENV PATH variable
- In Linux flavours, Copy the terraform executable in /usr/bin path to execute it from any path.
 
## Steps to spin up the GCE instance in Google Cloud 
- This source can be used to create GCE instance in Google Cloud
- Instance details, centos-7 on GCE instance type "n1-standard-1 (1 vCPU and ~4GB RAM)"

## Source File Details
  - gcp-vm.tf - Terraform config file

```
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
  }

  metadata_startup_script = file(var.metadata_script)

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.source_account_email
    scopes = ["cloud-platform"]
  }
}
```

  - variables.tf - Terraform variables declaration

```
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
variable "service_account_email" {
  default = "dummy_service_account_email"
}
variable "metadata_script" {
  default = "initscript_chef.sh"
}
variable "creds_file" {
  default = ".keys/account.json"
}
```

  - gcp-vm-vars.tfvars - Terraform config variable file

```
gcp_project_id = "gcp_project_id"
service_account_email = "service_account_email"
region =  "us-central1"
zone = "us-central1-c"
vm_name = "tf-gcp-vm"
vm_type = "n1-standard-1"
vm_image = "centos-cloud/centos-7"
vm_image_type = "pd-standard"

```

  - initscript_chef.sh - The metadata script, used to install packages while the install is first available

```
#!/bin/bash
mkdir -p /data/chef_cookbooks
rm -rf /data/chef_cookbooks/*
outfile='/var/log/userdata.out'

# Install Chef client v14
if [ ! -f /usr/bin/chef-client ] ; then
echo "Installing chef client" >> $outfile
curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v 15.8.23 >> $outfile
fi

# Install git
if [ ! -f /usr/bin/git ] ; then
yum install git -y >> $outfile
fi

# Clone Chef cookbook repo
cd /data/chef_cookbooks
echo "Cookbook Repo cloning" >> $outfile 
git clone https://github.com/chefgs/cookbooks.git >> $outfile

echo "Executing chef-client" >> $outfile
cd /data/chef_cookbooks
sudo chef-client -z -o apache --chef-license accept >> /var/log/chefrun.out
##
if [ -d /var/www/html/ ] ; then
echo "Apache server created successfully, hence create sample html site" >> $outfile
cat  <<'EOF' >> /var/www/html/index.html
<html><body><p>Apache server in Google Cloud</p>
<p>Created using metadata startup script from a local script file.</p></body></html>
EOF
fi

```

## Execute Resource Creation
- Create the .tfvars file and edit/save the variable section to add the below variables specific to your Google cloud project, 
    - gcp_project_id
    - service_account_email
- Go to .keys directory and copy the content of GCP project service account KEY JSON, created in Pre-requisite step 2-B. File should be named as `account.json`
- Run the below commands from the path where .tf is located to spin up GCE instance,
```
terraform init
terraform plan -var-file=gcp-vm-vars.tfvars
terraform apply -var-file=gcp-vm-vars.tfvars -auto-approve
```

- This completes the creation of GCE instance in Google cloud using terraform


 
