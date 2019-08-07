## Google Cloud Computing Engine creation using Terraform

### Objective
- Terraform example of creating an immutable instance on Google Cloud
- This source can be used to create GCE instance in Google Cloud
- Instance details, centos-7 on GCE instance type "n1-standard-1 (1 vCPU and ~4GB RAM)"
- GCE instance will be having below configurations set when the instances creation is completed 
    - Should be having Git, Ansible and wget pre-installed
    - Set a hostname on operating system level 
    - Install a package called “my-monitoring-agent”. The RPM package is already configured in the script 
    - Set the hostname in the configuration of the monitoring agent. Config file located at “/etc/mon-agent/agent.conf” 
    - Ensure that the two users exists and are part of the group “staffs”

### Important Pre-Requisites
1. Create a project in the Google Cloud Console and set up billing on that project. 
2. #### Adding credential
    - A. In order to make requests against the GCP API, you need to authenticate to prove that it's you making the request. The preferred method of provisioning resources with Terraform is to use a [GCP service account](https://cloud.google.com/docs/authentication/getting-started), a "robot account" that can be granted a limited set of IAM permissions.

    - B. From the [service account key page](https://console.cloud.google.com/apis/credentials/serviceaccountkey) in the Cloud Console choose an existing account, or create a new one. Next, download the JSON key file. Name it something you can remember, and store it somewhere secure on your machine.
3. Refer Google Cloud documentation on creating [Service account here](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account)

### Install and Configure Terraform
- Refer here [for installing terraform](https://www.terraform.io/downloads.html)
- Download and extract the terraform executable
- Add terraform executable path to ENV PATH variable
- In Linux flavours, Copy the terraform executable in /usr/bin path to execute it from any path.
 
### Steps to spin up the GCE instance in Google Cloud 
 1. Clone the repository terraform_repo
 2. cd terraform_repo/gcp_resources
 #### Source File Details
   - gcp-vm.tf - Terraform config file
   - gcp-vm-vars.tfvars - Terraform config variable file
   - initscript.sh - The metadata script, used to install packages while the install is first available

 3. Open the .tfvars file and edit/save the variable section to add the below variables specific to your Google cloud project, 
     - gcp_project_id
     - service_account_email
 4. Go to .keys directory and copy the content of GCP project account json, created in Pre-requisite step 2-B. File should be named as account.json
 5. Run the below commands from the path where .tf is located to spin up GCE instance,
 ```
 terraform init
 terraform apply -var-file=gcp-vm-vars.tfvars
 ```
 type "yes" when prompted<br>
 6. This completes the creation of GCE instance in Google cloud using terraform.
 
