output "consul_asg_name" {
  description = "Name of the Consul server Auto Scaling Group."
  value       = aws_autoscaling_group.consul_servers.name
}

output "consul_security_group_id" {
  description = "Security group ID for Consul servers."
  value       = aws_security_group.consul_servers.id
}

output "consul_server_iam_role_arn" {
  description = "ARN of the Consul server IAM role."
  value       = aws_iam_role.consul_server.arn
}
