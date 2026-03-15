output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "web_security_group_id" {
  description = "Web tier security group ID."
  value       = module.web_sg.security_group_id
}

output "app_security_group_id" {
  description = "App tier security group ID."
  value       = module.app_sg.security_group_id
}
