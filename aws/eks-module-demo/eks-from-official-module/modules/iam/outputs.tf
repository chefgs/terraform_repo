output "eks_cluster_role_name" {
  description = "EKS Cluster IAM Role Name"
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_group_role_arn" {
  description = "EKS Node Group IAM Role ARN"
  value       = aws_iam_role.eks_node_group_role.arn
}
