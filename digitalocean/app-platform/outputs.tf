##############################################################################
# Outputs – DigitalOcean App Platform
##############################################################################

output "app_id" {
  description = "The unique ID of the App Platform application."
  value       = digitalocean_app.app.id
}

output "app_live_url" {
  description = "The live URL of the deployed App Platform application."
  value       = digitalocean_app.app.live_url
}

output "app_default_ingress" {
  description = "The default ingress URL assigned by DigitalOcean."
  value       = digitalocean_app.app.default_ingress
}

output "project_id" {
  description = "The ID of the DigitalOcean Project that groups app resources."
  value       = digitalocean_project.app_project.id
}

output "project_urn" {
  description = "The URN of the DigitalOcean Project."
  value       = digitalocean_project.app_project.urn
}

output "active_deployment_id" {
  description = "The ID of the currently active deployment."
  value       = digitalocean_app.app.active_deployment_id
}
