##############################################################################
# DigitalOcean App Platform – IaC with Project & Git Variable Support
#
# This example provisions:
#   1. A DigitalOcean Project to group all app-platform resources
#   2. A DigitalOcean App Platform application sourced from a Git repository
#   3. A project-level git variable (e.g. build-time secret / env var)
#   4. Associates the App with the Project
##############################################################################

# ── Project ────────────────────────────────────────────────────────────────
resource "digitalocean_project" "app_project" {
  name        = var.project_name
  description = "Project for ${var.app_name} App Platform deployment"
  purpose     = "Web Application"
  environment = var.environment
}

# ── App Platform Application ───────────────────────────────────────────────
resource "digitalocean_app" "app" {
  spec {
    name   = var.app_name
    region = var.region

    # ── Git source ────────────────────────────────────────────────────────
    service {
      name               = var.app_name
      environment_slug   = var.runtime_environment_slug
      instance_count     = var.instance_count
      instance_size_slug = var.instance_size_slug

      git {
        repo_clone_url = var.git_repo_url
        branch         = var.git_branch
      }

      # Build command (optional — adjust per runtime)
      build_command = var.build_command
      run_command   = var.run_command

      # HTTP port the application listens on
      http_port = var.http_port

      # Health check
      health_check {
        http_path             = var.health_check_path
        initial_delay_seconds = 10
        period_seconds        = 30
        timeout_seconds       = 5
        success_threshold     = 1
        failure_threshold     = 3
      }

      # ── Environment variables (project-level git variable injected here) ──
      dynamic "env" {
        for_each = var.app_env_vars
        content {
          key   = env.value.key
          value = env.value.value
          scope = env.value.scope
          type  = env.value.type
        }
      }
    }

    # ── Ingress / routing ─────────────────────────────────────────────────
    ingress {
      rule {
        component {
          name = var.app_name
        }
        match {
          path {
            prefix = "/"
          }
        }
      }
    }
  }
}

# ── Associate the App with the Project ────────────────────────────────────
resource "digitalocean_project_resources" "app_project_resources" {
  project = digitalocean_project.app_project.id

  resources = [
    digitalocean_app.app.urn,
  ]
}
