variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "2tier-app"
}

variable "org_name" {
  type    = string
  default = "my-org"
}

variable "boundary_addr" {
  description = "Boundary controller address (e.g. https://boundary.example.com)"
  type        = string
  default     = "https://127.0.0.1:9200"
}

variable "boundary_auth_method_id" {
  description = "Auth method ID for Boundary (ampassword_xxx or amoidc_xxx)"
  type        = string
}

variable "boundary_login_name" {
  description = "Admin login name for Boundary provider authentication."
  type        = string
  default     = "admin"
}

variable "boundary_password" {
  description = "Admin password for Boundary provider authentication."
  type        = string
  sensitive   = true
}

variable "vault_address" {
  description = "Vault address for Boundary credential store."
  type        = string
  default     = "https://127.0.0.1:8200"
}

variable "vault_token" {
  description = "Vault token for Boundary credential store integration."
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS access key for Boundary dynamic host catalog."
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret key for Boundary dynamic host catalog."
  type        = string
  sensitive   = true
}

variable "enable_session_recording" {
  description = "Enable session recording for audit (requires Boundary Enterprise or HCP Boundary)."
  type        = bool
  default     = false
}

variable "dev_users" {
  description = "Map of developer users to create in Boundary."
  type = map(object({
    name       = string
    login_name = string
    password   = string
  }))
  default = {}
  sensitive = true
}

variable "ops_users" {
  description = "Map of operations users to create in Boundary."
  type = map(object({
    name       = string
    login_name = string
    password   = string
  }))
  default = {}
  sensitive = true
}
