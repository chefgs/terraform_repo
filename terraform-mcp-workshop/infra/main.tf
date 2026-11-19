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
  type    = number
  default = 8080
  validation {
    condition     = var.host_port >= 1024 && var.host_port <= 65535 && floor(var.host_port) == var.host_port
    error_message = "Use an integer port between 1024 and 65535."
  }
}

resource "docker_image" "web" {
  name         = "nginx:1.28-alpine"
  keep_locally = true
}

resource "docker_network" "lab" {
  name = "meeting-pulse-lab"
}

resource "docker_container" "web" {
  name  = "meeting-pulse-web"
  image = docker_image.web.image_id

  ports {
    internal = 80
    external = var.host_port
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.lab.name
  }

  volumes {
    host_path      = abspath("${path.module}/../site")
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }
}

output "application_url" {
  value = "http://127.0.0.1:${var.host_port}"
}
