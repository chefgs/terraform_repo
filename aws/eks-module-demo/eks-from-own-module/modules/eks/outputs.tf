output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "node_group_role_arn" {
  value = aws_eks_node_group.eks_node_group.node_role_arn
}
