##############################################################################
# Variables – DigitalOcean App Platform
##############################################################################

# ── Auth ──────────────────────────────────────────────────────────────────
variable "do_token" {
  description = "DigitalOcean personal access token. Set via TF_VAR_do_token or terraform.tfvars."
  type        = string
  sensitive   = true
}

# ── Project ────────────────────────────────────────────────────────────────
variable "project_name" {
  description = "Name for the DigitalOcean Project that groups app-platform resources."
  type        = string
  default     = "my-app-project"
}

variable "environment" {
  description = "Project environment (Development | Staging | Production)."
  type        = string
  default     = "Development"

  validation {
    condition     = contains(["Development", "Staging", "Production"], var.environment)
    error_message = "environment must be one of: Development, Staging, Production."
  }
}

# ── App Platform ───────────────────────────────────────────────────────────
variable "app_name" {
  description = "Name for the App Platform application (must be unique per account)."
  type        = string
  default     = "my-web-app"
}

variable "region" {
  description = "DigitalOcean region slug for the App Platform app."
  type        = string
  default     = "nyc3"
}

variable "runtime_environment_slug" {
  description = "Runtime environment slug (e.g. node-js, python, dockerfile, static)."
  type        = string
  default     = "node-js"
}

variable "instance_count" {
  description = "Number of running instances for the service component."
  type        = number
  default     = 1
}

variable "instance_size_slug" {
  description = "Instance size slug (e.g. basic-xxs, basic-xs, basic-s, professional-xs)."
  type        = string
  default     = "basic-xxs"
}

variable "http_port" {
  description = "HTTP port the application process listens on."
  type        = number
  default     = 8080
}

# ── Git Source ─────────────────────────────────────────────────────────────
variable "git_repo_url" {
  description = "Public or private Git repository clone URL (HTTPS)."
  type        = string
  # Example: "https://github.com/your-org/your-app.git"
}

variable "git_branch" {
  description = "Git branch to deploy from."
  type        = string
  default     = "main"
}

# ── Build / Run ────────────────────────────────────────────────────────────
variable "build_command" {
  description = "Command used to build the application (leave empty to use auto-detection)."
  type        = string
  default     = ""
}

variable "run_command" {
  description = "Command used to start the application (leave empty to use auto-detection)."
  type        = string
  default     = ""
}

# ── Health Check ───────────────────────────────────────────────────────────
variable "health_check_path" {
  description = "HTTP path for the App Platform health check."
  type        = string
  default     = "/"
}

# ── Environment Variables (including Git Variable) ─────────────────────────
variable "app_env_vars" {
  description = <<-EOT
    List of environment variables to inject into the app service.
    Each object supports:
      key   – variable name
      value – variable value (can reference a project git variable via \${{VARIABLE_NAME}})
      scope – RUN_TIME | BUILD_TIME | RUN_AND_BUILD_TIME
      type  – GENERAL | SECRET

    To pass a DigitalOcean project-level git variable use the special
    reference syntax supported by App Platform:
      value = "$${GIT_VARIABLE_NAME}"
  EOT
  type = list(object({
    key   = string
    value = string
    scope = string
    type  = string
  }))
  default = [
    {
      key   = "APP_ENV"
      value = "production"
      scope = "RUN_AND_BUILD_TIME"
      type  = "GENERAL"
    },
    # Example showing project git variable reference:
    # {
    #   key   = "API_SECRET"
    #   value = "$${PROJECT_GIT_VARIABLE_NAME}"
    #   scope = "RUN_AND_BUILD_TIME"
    #   type  = "SECRET"
    # }
  ]
}
