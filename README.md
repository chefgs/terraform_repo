# terraform_repo
<h1>
  Instructions
  </h1>
 
 <h2>
  Install and Configure Terraform
  </h2>
  Refer here <a href="https://www.terraform.io/downloads.html">for installing terraform</a><br>
  Add terraform executable path to ENV variables
  
 
 <h2>
  Steps to spin up the infra using Terraform
  </h2>
 1. Clone the repository terraform_repo<br>
 2. cd terraform_repo<br>
 3. Open the .tf file and edit/save the variable section to add the AWS access key, secret key and account id.<br>
 Run the below commands from the path where .tf is located to spin up Elastic search single node cluster,<br>
 3. terraform init<br>
 4. terraform apply<br>
