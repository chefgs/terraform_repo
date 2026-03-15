# Create Apache Webserver in AWS Using Terraform
## Installation of required AWS packages
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- Configure [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/configure/)
- Please note, Configuring AWS using `aws configure` CLI command, will write the AWS secret and access key to `~/$USER_HOME/.aws/credentials` file and it will used to authenticate the terraform infra creation in AWS.

##  Install and Configure Terraform
- Refer here [for installing terraform](https://www.terraform.io/downloads.html)
- Extract and Add `terraform` executable path to ENV variables

## Terraform setup in Linux based systems
- Refer official [terraform docs](https://www.terraform.io/downloads) for OS specific installation
- Otherwise download the binary and extract it to /usr/local/bin (on Ubuntu system)
```
wget https://releases.hashicorp.com/terraform/1.2.1/terraform_1.2.1_linux_amd64.zip
unzip terraform_1.2.1_linux_amd64.zip -d terraform /usr/local/bin/
```
If terraform executable stored in another path, make sure the path is added in `$PATH` variable permanently.

## AWS Infrastructure Automation
- We will see How to automate the AWS infrastructure creation using Terraform
- As part of the demo code, we will create a Apache webserver and run a sample website
- Architecture of this server follows the single tier method, wherein we will create only a simple Webserver for demo purpose

## Basic Terminologies in Terraform
- Providers
  - It should be cloud provider or on-premise provider on which we will create our infrastructure and resources
- Resources
  - This indicates the resources like virtual machines, network components, containers we spin-up on the providers
- Tfstate file
  - This is the state of terraform infrastructure created when we run the commands `terraform plan` and `terraform apply`
  - This state file can be stored locally or in a network storage for multi developer environments

## Source Code File Details
- `main.tf` contains the beginning section of terraform code
- So we have to define `terraform` with `required_providers` and we have mentioned `aws` since we are going to create infra in AWS

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.0"
}
```
- We have already installed and configured `aws cli` authentication details pointing to the destination AWS account on which the infrastructure will be created
- The configured credentials stored in the file `~/.aws.credentials`
- In older Terraform implementation, We need to provide the reference for the above path in `shared_credentials_file` value using the `creds` variable
- But in latest Terraform implementation, the AWS credentials are read automatically by Terraform provider and we don't have to mention the path of `~/.aws.credentials`
- Refer the Terraform docs regarding [AWS authentication and config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
```
# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_file = var.creds # Optional
  profile = "default"
}
```
- Rest of the `main.tf` should have the resource definition required for creating a `AWS EC2` instance
- We need to have below resources for creating an EC2 instance
  1. VPC
  2. Internet Gateway
  3. Subnet
  4. Route table
  5. Security Group
and then,
  5. EC2 instance definition

```
# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```
## Cloud Init and User Data
- Objective of the EC2 instance is to have the Apache Web Server installed on it, when the instance is created
- So we are providing a shell script in `user_data` section to install the apache server
- The script added in `user_data` section will be invoked via `Cloud Init` functionality when the AWS server gets created
- So what ever the commands added in `user_data` section gets executed whenever the instance getting initialized
- We can provide any kind scripts in user_data like the example below,
  1. Shell script in Unix based systems
  2. Powershell script in Windows based system
```
resource "aws_instance" "web" {
  ami             = "ami-0d70546e43a941d70" 
  instance_type   = var.instance_type
  key_name        = var.instance_key
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "web_instance"
  }

  volume_tags = {
    Name = "web_instance"
  } 
}
```
- `variables.tf` file should have the customised variables, a user wanted to provide before running the infra creation
- User can also define default value for each variable in the file, just in case, it will be used as default value, if no `tfvars` file is passed as input arg.
 
```
variable "region" {
default = "us-west-2"
}
variable "instance_type" {}
variable "creds" {}
variable "instance_key" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
```
- It is recommended to create separate tf files for separating various resources
- So we have crreated `sg.tf` file for adding resource for AWS VPC security group
- sg.tf
```
resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}
```
- We can define `output.tf` file to see expected output values like `ipaddress` of instances and `hostname` etc.

- output.tf
```
output "web_instance_ip" {
    value = aws_instance.web.public_ip
}
```
- Since we have the custom variables defined in our terraform file, we have provide the values for those custom variables
- So we have to create a `tfvars` files and provide the custom variable values
- User has to provide the EC2 instance `pem file` key name in `instance_key` value
- aws.tfvars
```
region =  "us-west-2"
instance_type = "t2.micro"
instance_key = "aws_ec2_pem_file_name"
creds = "~/.aws/credentials"
vpc_cidr = "178.0.0.0/16"
public_subnet_cidr = "178.0.10.0/24"
```

## Steps to run Terraform
```
terraform init
terraform plan -var-file=aws.tfvars
terraform apply -var-file=aws.tfvars -auto-approve
```
- `terraform init` - Initializes the terraform directory and download neccessary provider files and creates a `.terraform.lock.hcl` file
```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.75.2...
- Installed hashicorp/aws v3.75.2 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
- `terraform plan` shows the indicative resources list, and argument values and checks the authentication with AWS
- Also it shows the details of resource changes, additions and destructions
```
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-0d70546e43a941d70"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
.
.
.
.

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + web_instance_ip = (known after apply)
```
- `terraform apply` command actually deployes the resources to the corresponding provider
- Once the `terrform apply` completed successfully it will show the `public ipaddress` of the apache server as `output`
- It asks for confirmation `yes` to proceed. It can be skipped using the option `-auto-approve` but it needs to be used with caution in real-time environments
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.app_vpc: Creating...
.
.
.

aws_instance.web: Creation complete after 33s [id=i-07f19000878a6ec11]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

web_instance_ip = "34.220.248.140"
``` 
## Access the Webserver
- We can access the webserver using the public IP
- Screenshot Below,

![Apache WebServer Page](https://github.com/chefgs/repo_images/blob/master/apache2page.png?raw=true)

## Cleanup 
- As part of learning we will also cleanup the server using the command,
- Similar to `apply` command, `destroy` command also asks for confirmation `yes` to proceed. It can be skipped using the option `-auto-approve` but it needs to be used with caution in real-time environments
```
terraform destroy -var-file=aws.tfvars -auto-approve
```
- It shows the destruction completed console log
```
Changes to Outputs:
  - web_instance_ip = "34.220.248.140" -> null
aws_route_table_association.public_rt_asso: Destroying... [id=rtbassoc-085573ee447b7d0d1]
aws_instance.web: Destroying... [id=i-07f19000878a6ec11]
aws_route_table_association.public_rt_asso: Destruction complete after 0s
aws_route_table.public_rt: Destroying... [id=rtb-04025de8f9149983a]
aws_route_table.public_rt: Destruction complete after 0s
aws_internet_gateway.igw: Destroying... [id=igw-06269b7b96264af8f]
aws_instance.web: Still destroying... [id=i-07f19000878a6ec11, 10s elapsed]
aws_internet_gateway.igw: Still destroying... [id=igw-06269b7b96264af8f, 10s elapsed]
aws_internet_gateway.igw: Destruction complete after 19s
aws_instance.web: Still destroying... [id=i-07f19000878a6ec11, 20s elapsed]
aws_instance.web: Still destroying... [id=i-07f19000878a6ec11, 30s elapsed]
aws_instance.web: Destruction complete after 30s
aws_subnet.public_subnet: Destroying... [id=subnet-06304b3b7eb727669]
aws_security_group.sg: Destroying... [id=sg-098709b525d3553b7]
aws_security_group.sg: Destruction complete after 0s
aws_subnet.public_subnet: Destruction complete after 0s
aws_vpc.app_vpc: Destroying... [id=vpc-05f7555059de86cf6]
aws_vpc.app_vpc: Destruction complete after 0s

Destroy complete! Resources: 7 destroyed.
```
.
