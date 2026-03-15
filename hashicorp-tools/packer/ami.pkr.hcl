packer {
  required_version = ">= 1.9.0"
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.0"
    }
  }
}

# ── Variables ────────────────────────────────────────────────────────────
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_version" {
  type    = string
  default = "1.0.0"
}

variable "environment" {
  type    = string
  default = "prod"
}

# ── Data sources ─────────────────────────────────────────────────────────
# Find latest Amazon Linux 2023 AMI
data "amazon-ami" "amazon_linux_2023" {
  filters = {
    name                = "al2023-ami-*-x86_64"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws_region
  profile     = var.aws_profile
}

# ── Web Tier AMI ─────────────────────────────────────────────────────────
source "amazon-ebs" "web_server" {
  profile       = var.aws_profile
  region        = var.aws_region
  source_ami    = data.amazon-ami.amazon_linux_2023.id
  instance_type = var.instance_type
  ssh_username  = "ec2-user"

  ami_name        = "2tier-web-server-${var.app_version}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "Web server AMI for 2-tier app (Nginx + Consul agent)"

  tags = {
    Name        = "2tier-web-server"
    Version     = var.app_version
    Tier        = "web"
    Environment = var.environment
    ManagedBy   = "Packer"
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
}

# ── App Tier AMI ─────────────────────────────────────────────────────────
source "amazon-ebs" "app_server" {
  profile       = var.aws_profile
  region        = var.aws_region
  source_ami    = data.amazon-ami.amazon_linux_2023.id
  instance_type = var.instance_type
  ssh_username  = "ec2-user"

  ami_name        = "2tier-app-server-${var.app_version}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "App server AMI for 2-tier app (Node.js + Consul agent + Vault agent)"

  tags = {
    Name        = "2tier-app-server"
    Version     = var.app_version
    Tier        = "app"
    Environment = var.environment
    ManagedBy   = "Packer"
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
}

# ── Builds ────────────────────────────────────────────────────────────────
build {
  name = "web-server"
  sources = ["source.amazon-ebs.web_server"]

  # Install and harden base OS
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y nginx unzip jq awscli",
      "sudo systemctl enable nginx",
    ]
  }

  # Install Consul agent
  provisioner "shell" {
    scripts = ["scripts/install_consul.sh"]
  }

  # Configure Nginx as reverse proxy
  provisioner "file" {
    source      = "config/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo nginx -t",
    ]
  }

  # CIS hardening
  provisioner "shell" {
    scripts = ["scripts/harden.sh"]
  }
}

build {
  name = "app-server"
  sources = ["source.amazon-ebs.app_server"]

  # Install Node.js + Vault agent + Consul agent
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y nodejs unzip jq awscli",
      "curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -",
      "sudo dnf install -y nodejs",
    ]
  }

  provisioner "shell" {
    scripts = [
      "scripts/install_consul.sh",
      "scripts/install_vault_agent.sh",
    ]
  }

  provisioner "shell" {
    scripts = ["scripts/harden.sh"]
  }
}
