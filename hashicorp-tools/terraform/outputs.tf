##############################################################################
# Outputs – 2-Tier AWS Application Infrastructure
##############################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "DNS name of the public-facing Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the public-facing ALB (for Route 53 alias records)"
  value       = aws_lb.web.zone_id
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal Application Load Balancer (app tier)"
  value       = aws_lb.app.dns_name
}

output "web_asg_name" {
  description = "Name of the web tier Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  description = "Name of the app tier Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "Port for the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.port
}
