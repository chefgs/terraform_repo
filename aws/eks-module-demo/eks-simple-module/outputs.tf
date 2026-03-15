# Outputs
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value = module.eks.cluster_name
}

output "eks_managed_node_groups" {
  description = "EKS Managed Node Groups"
  value       = module.eks.eks_managed_node_groups
}