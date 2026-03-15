output "web_instance_profile_arn" {
  description = "ARN of the IAM instance profile for web-tier EC2 instances."
  value       = aws_iam_instance_profile.web.arn
}

output "app_instance_profile_arn" {
  description = "ARN of the IAM instance profile for app-tier EC2 instances."
  value       = aws_iam_instance_profile.app.arn
}

output "kv_mount_path" {
  description = "Vault KV v2 mount path."
  value       = vault_mount.kv.path
}

output "db_mount_path" {
  description = "Vault Database secrets engine mount path."
  value       = vault_mount.db.path
}

output "pki_ca_serial" {
  description = "Serial number of the root CA certificate."
  value       = vault_pki_secret_backend_root_cert.ca.serial_number
}
