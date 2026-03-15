# =============================================================================
# outputs.tf
#
# Useful values exposed after a successful `terraform apply`.
# =============================================================================

output "rag_instance_ami" {
  description = "AMI used by the GPU instance (resolved at plan time)."
  value       = local.resolved_ami
}

output "vpc_id" {
  description = "ID of the VPC created for the RAG deployment."
  value       = aws_vpc.rag_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet that hosts the GPU instance."
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the security group attached to the GPU instance."
  value       = aws_security_group.rag_sg.id
}

output "rag_instance_id" {
  description = "EC2 instance ID of the NVIDIA GPU host running the RAG application."
  value       = aws_instance.rag_gpu.id
}

output "rag_instance_public_ip" {
  description = "Public IP address of the GPU instance (available once the instance is running)."
  value       = aws_instance.rag_gpu.public_ip
}

output "rag_instance_public_dns" {
  description = "Public DNS name of the GPU instance."
  value       = aws_instance.rag_gpu.public_dns
}

output "rag_app_url" {
  description = "URL to reach the RAG application API once the instance is running."
  value       = "http://${aws_instance.rag_gpu.public_ip}:${var.app_port}"
}

output "rag_docs_s3_bucket" {
  description = "Name of the S3 bucket used for document and FAISS index storage."
  value       = aws_s3_bucket.rag_docs.bucket
}

output "rag_docs_s3_bucket_arn" {
  description = "ARN of the S3 documents bucket."
  value       = aws_s3_bucket.rag_docs.arn
}

output "iam_instance_role_arn" {
  description = "ARN of the IAM role attached to the GPU instance."
  value       = aws_iam_role.rag_instance_role.arn
}

output "ssh_command" {
  description = "Example SSH command to connect to the GPU instance (requires a valid key pair)."
  value       = var.key_pair_name != "" ? "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.rag_gpu.public_ip}" : "No key pair specified – SSH access not configured."
}
