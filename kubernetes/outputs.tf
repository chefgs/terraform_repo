############################
# KUBERNETES OUTPUTS
############################

output "namespace_name" {
  description = "The name of the created Kubernetes namespace"
  value       = kubernetes_namespace.example.metadata[0].name
}

output "namespace_uid" {
  description = "The UID of the created Kubernetes namespace"
  value       = kubernetes_namespace.example.metadata[0].uid
}

# Removed namespace_status output as status is not directly accessible

output "deployment_name" {
  description = "The name of the created Kubernetes deployment"
  value       = kubernetes_deployment.example.metadata[0].name
}

output "deployment_generation" {
  description = "The generation of the deployment"
  value       = kubernetes_deployment.example.metadata[0].generation
}

output "deployment_replicas" {
  description = "The number of replicas in the deployment"
  value       = kubernetes_deployment.example.spec[0].replicas
}

# Removed status-related outputs as they are not directly accessible in the provider

output "service_name" {
  description = "The name of the created Kubernetes service"
  value       = kubernetes_service.example.metadata[0].name
}

output "service_cluster_ip" {
  description = "The cluster IP of the service"
  value       = kubernetes_service.example.spec[0].cluster_ip
}

output "service_ports" {
  description = "The ports exposed by the service"
  value       = kubernetes_service.example.spec[0].port[*].port
}

output "resource_quota_status" {
  description = "The status of the resource quota"
  value       = kubernetes_resource_quota.example.spec[0].hard
}

output "container_image" {
  description = "The container image used in the deployment"
  value       = var.container_image
}

output "kubernetes_connection_info" {
  description = "Information about the Kubernetes connection"
  value = {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
  sensitive = false
}

output "service_endpoint" {
  description = "How to access the service (instructions)"
  value       = "To access the service within the cluster, use: ${kubernetes_service.example.metadata[0].name}.${kubernetes_namespace.example.metadata[0].name}.svc.cluster.local"
}

output "deployment_labels" {
  description = "Labels applied to the deployment"
  value       = kubernetes_deployment.example.metadata[0].labels
}

output "pod_security_settings" {
  description = "Security settings applied to the pods"
  value = {
    run_as_non_root           = true
    read_only_root_filesystem = true
  }
}
