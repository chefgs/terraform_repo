output "org_id" {
  description = "Boundary organization scope ID."
  value       = boundary_scope.org.id
}

output "project_prod_id" {
  description = "Boundary production project scope ID."
  value       = boundary_scope.project_prod.id
}

output "web_ssh_target_id" {
  description = "Boundary target ID for web-tier SSH access."
  value       = boundary_target.web_ssh.id
}

output "app_ssh_target_id" {
  description = "Boundary target ID for app-tier SSH access."
  value       = boundary_target.app_ssh.id
}

output "connect_web_cmd" {
  description = "Example command to connect to a web-tier instance via Boundary."
  value       = "boundary connect ssh -target-id=${boundary_target.web_ssh.id} -username ec2-user"
}

output "connect_app_cmd" {
  description = "Example command to connect to an app-tier instance via Boundary."
  value       = "boundary connect ssh -target-id=${boundary_target.app_ssh.id} -username ec2-user"
}
