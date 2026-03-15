##############################################################################
# Variables – Oracle Cloud Infrastructure Basic Compute
##############################################################################

# ── OCI Auth ──────────────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy."
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID of the OCI user for authentication."
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint of the API key pair used for authentication."
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the OCI API private key file (.pem)."
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "OCI region identifier (e.g. us-ashburn-1, us-phoenix-1)."
  type        = string
  default     = "us-ashburn-1"
}

# ── Compartment ───────────────────────────────────────────────────────────
variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created. Defaults to tenancy root."
  type        = string
}

# ── Project ────────────────────────────────────────────────────────────────
variable "project_name" {
  description = "Prefix used for all resource display names."
  type        = string
  default     = "tf-oci-demo"
}

variable "environment" {
  description = "Deployment environment tag (dev | staging | prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# ── Networking ────────────────────────────────────────────────────────────
variable "vcn_cidr_block" {
  description = "CIDR block for the Virtual Cloud Network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

# ── Compute ───────────────────────────────────────────────────────────────
variable "instance_shape" {
  description = "OCI Compute shape. Use VM.Standard.E4.Flex for ARM-based Ampere free-tier."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for flexible shapes."
  type        = number
  default     = 1
}

variable "instance_memory_gb" {
  description = "Amount of memory in GB for flexible shapes."
  type        = number
  default     = 8
}

variable "os_version" {
  description = "Oracle Linux OS version."
  type        = string
  default     = "9"
}

variable "ssh_public_key" {
  description = "SSH public key content for instance access."
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloud_init_script" {
  description = "Cloud-init shell script to run on first boot."
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Deployed via Terraform on OCI</h1>" > /var/www/html/index.html
  EOF
}
