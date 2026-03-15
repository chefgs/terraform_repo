variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "2tier-app"
}

variable "vault_address" {
  description = "URL of the Vault cluster (e.g. https://vault.example.com:8200)"
  type        = string
  default     = "https://127.0.0.1:8200"
}

variable "vault_root_token" {
  description = "Vault root token for bootstrapping. Use AppRole or AWS auth for production."
  type        = string
  sensitive   = true
}

variable "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (hostname:port)"
  type        = string
}

variable "db_admin_username" {
  description = "Master DB admin username for Vault dynamic credentials"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Master DB admin password for Vault dynamic credentials"
  type        = string
  sensitive   = true
}
