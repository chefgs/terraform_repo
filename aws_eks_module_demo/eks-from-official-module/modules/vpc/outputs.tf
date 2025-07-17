output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}
