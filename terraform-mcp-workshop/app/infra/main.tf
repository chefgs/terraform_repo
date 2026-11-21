# Meeting Session Pulse: the poll app (app/server.py) in one local Docker container.
#
# Scope: exactly the approved architecture. One container, one named volume for the
# SQLite file, one pulled image. No network resource, no restart policy, no `wait`.
# Local Docker only: uses the inherited DOCKER_HOST. No credentials, provisioners,
# remote hosts or Docker socket mounts.
#
# The static lab in ../../infra uses different names and port 8080, so both can exist.

terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {}

variable "host_port" {
  description = "Host port for the poll. Published on 127.0.0.1 only. The server's own default is 8000."
  type        = number
  default     = 8000
  validation {
    condition     = var.host_port >= 1024 && var.host_port <= 65535 && floor(var.host_port) == var.host_port
    error_message = "Use a whole number between 1024 and 65535 for host_port."
  }
}

variable "python_image" {
  description = "Public image that runs server.py. app/README.md says it was tested on Python 3.15.2 only. Whether this tag exists and pulls is not checked by a plan."
  type        = string
  default     = "python:3.15-alpine"
}

resource "docker_image" "api" {
  name         = var.python_image
  keep_locally = true
}

# The votes. A named volume survives replacing the container, but `terraform destroy`
# deletes it and every vote with it. Review any destroy plan for this resource.
resource "docker_volume" "data" {
  name = "meeting-pulse-poll-data"
}

resource "docker_container" "api" {
  name    = "meeting-pulse-poll"
  image   = docker_image.api.image_id
  command = ["python3", "/app/server.py"]

  # server.py reads these. PULSE_HOST=0.0.0.0 is for inside the container only; the
  # host-side exposure is limited by `ports.ip` below. That this combination works is
  # what app/README.md says. It has not been tested here.
  env = [
    "PULSE_HOST=0.0.0.0",
    "PULSE_PORT=8000",
    "PULSE_DB=/data/pulse.db",
  ]

  # Loopback only on the host. `ip` defaults to 0.0.0.0 in the provider, so it is set
  # explicitly and is deliberately not a variable.
  ports {
    internal = 8000
    external = var.host_port
    ip       = "127.0.0.1"
  }

  # App files, read-only. Not the whole app/ folder: that would expose data/ and infra/.
  volumes {
    host_path      = abspath("${path.module}/../server.py")
    container_path = "/app/server.py"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../static")
    container_path = "/app/static"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/data"
  }

  # Provider defaults for these durations are 0s, so they are set explicitly.
  healthcheck {
    test         = ["CMD", "python3", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/api/health', timeout=3)"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 3
    start_period = "5s"
  }
}

output "application_url" {
  description = "Where the poll is reachable on this computer."
  value       = "http://127.0.0.1:${var.host_port}"
}
