############################
# VARIABLES (for flexibility)
############################

variable "namespace" {
  description = "The name of the Kubernetes namespace"
  type        = string
  default     = "k8s-ns-by-tf"
}

variable "deployment_name" {
  description = "The name of the Kubernetes deployment"
  type        = string
  default     = "terraform-example"
}

variable "app_label" {
  description = "App label for Kubernetes resources"
  type        = string
  default     = "MyExampleApp"
}

variable "replica_count" {
  description = "Number of deployment replicas"
  type        = number
  default     = 2
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "nginxinc/nginx-unprivileged:1.25-alpine"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "example"
}

variable "resource_requests_cpu" {
  description = "CPU requests for the container"
  type        = string
  default     = "250m"
}

variable "resource_requests_memory" {
  description = "Memory requests for the container"
  type        = string
  default     = "50Mi"
}

variable "resource_limits_cpu" {
  description = "CPU limits for the container"
  type        = string
  default     = "500m"
}

variable "resource_limits_memory" {
  description = "Memory limits for the container"
  type        = string
  default     = "512Mi"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner annotation for resources"
  type        = string
  default     = "chefgs"
}