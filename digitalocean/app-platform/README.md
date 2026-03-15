# DigitalOcean App Platform – Terraform IaC

Deploy a production-ready application on **DigitalOcean App Platform** using Terraform, including DigitalOcean Projects and Git variable support.

## Features

- **App Platform App** – Deploys a service from a Git repository (public or private)
- **DigitalOcean Project** – Groups related resources under a named project
- **Environment Variables** – Supports static values and references to project-level Git variables (secrets)
- **Health Checks** – Configures HTTP health checks for production readiness
- **Lock File** – Pinned provider version for reproducible deployments

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.5.0 |
| DigitalOcean Provider | ~> 2.0 |
| DigitalOcean Account | – |

## Usage

```bash
# 1. Copy and populate the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your DO token and app settings

# 2. Initialise
terraform init

# 3. Preview the plan
terraform plan

# 4. Apply
terraform apply

# 5. Destroy when done
terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `do_token` | DigitalOcean API token | `string` | – | ✅ |
| `project_name` | DigitalOcean project name | `string` | `"my-app-project"` | No |
| `environment` | Project environment | `string` | `"Development"` | No |
| `app_name` | App Platform app name | `string` | `"my-web-app"` | No |
| `region` | DO region slug | `string` | `"nyc3"` | No |
| `git_repo_url` | Git repository clone URL | `string` | – | ✅ |
| `git_branch` | Git branch to deploy | `string` | `"main"` | No |
| `app_env_vars` | List of environment variables | `list(object)` | `[{APP_ENV=production}]` | No |

## Outputs

| Name | Description |
|------|-------------|
| `app_id` | App Platform application ID |
| `app_live_url` | Live URL of the deployed app |
| `app_default_ingress` | Default ingress URL |
| `project_id` | DigitalOcean project ID |
| `active_deployment_id` | Active deployment ID |

## Git Variables (Project-level Secrets)

DigitalOcean App Platform supports injecting **project-level Git variables** as environment variables using the special reference syntax:

```hcl
app_env_vars = [
  {
    key   = "DATABASE_URL"
    value = "$${GIT_DATABASE_URL}"   # references a project git variable
    scope = "RUN_AND_BUILD_TIME"
    type  = "SECRET"
  }
]
```

Create project-level variables in **DigitalOcean Console → Settings → Variables** or via the `doctl` CLI:

```bash
doctl apps create-deployment <app-id> --wait
```

## Resources Created

```
digitalocean_project.app_project
digitalocean_app.app
digitalocean_project_resources.app_project_resources
```
