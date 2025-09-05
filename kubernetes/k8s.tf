############################
# NAMESPACE
############################

resource "kubernetes_namespace" "example" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
    }
    annotations = {
      owner = var.owner
    }
  }
}

########################################
# RESOURCE QUOTA & LIMIT RANGE (optional)
########################################

resource "kubernetes_resource_quota" "example" {
  metadata {
    name      = "rq-example"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    hard = {
      "pods"           = 10
      "requests.cpu"   = "2"
      "requests.memory"= "2Gi"
      "limits.cpu"     = "4"
      "limits.memory"  = "4Gi"
    }
  }
}

resource "kubernetes_limit_range" "example" {
  metadata {
    name      = "lr-example"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.resource_limits_cpu
        memory = var.resource_limits_memory
      }
      default_request = {
        cpu    = var.resource_requests_cpu
        memory = var.resource_requests_memory
      }
    }
  }
}

############################
# DEPLOYMENT
############################

resource "kubernetes_deployment" "example" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.example.metadata[0].name
    labels = {
      app         = var.app_label
      environment = var.environment
    }
    annotations = {
      owner = var.owner
    }
  }
  
  # Add lifecycle block to handle recreation without errors
  lifecycle {
    create_before_destroy = true
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_label
      }
    }

    template {
      metadata {
        labels = {
          app         = var.app_label
          environment = var.environment
        }
        annotations = {
          owner = var.owner
        }
      }

      spec {
        container {
          image = var.container_image
          name  = var.container_name
          
          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = var.resource_limits_cpu
              memory = var.resource_limits_memory
            }
            requests = {
              cpu    = var.resource_requests_cpu
              memory = var.resource_requests_memory
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          security_context {
            run_as_non_root           = true
            read_only_root_filesystem = true
          }
          
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          
          volume_mount {
            name       = "var-cache-nginx"
            mount_path = "/var/cache/nginx"
          }
          
          volume_mount {
            name       = "var-run"
            mount_path = "/var/run"
          }
        }
        
        volume {
          name = "tmp"
          empty_dir {}
        }
        
        volume {
          name = "var-cache-nginx"
          empty_dir {}
        }
        
        volume {
          name = "var-run"
          empty_dir {}
        }
      }
    }
  }
}

############################
# SERVICE (to expose pods)
############################

resource "kubernetes_service" "example" {
  metadata {
    name      = "${var.deployment_name}-svc"
    namespace = kubernetes_namespace.example.metadata[0].name
    labels = {
      app = var.app_label
    }
  }

  spec {
    selector = {
      app = var.app_label
    }
    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}