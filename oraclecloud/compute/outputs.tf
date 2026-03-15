##############################################################################
# Outputs – Oracle Cloud Infrastructure Basic Compute
##############################################################################

output "instance_id" {
  description = "OCID of the compute instance."
  value       = oci_core_instance.compute.id
}

output "instance_public_ip" {
  description = "Public IP address of the compute instance."
  value       = oci_core_instance.compute.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the compute instance."
  value       = oci_core_instance.compute.private_ip
}

output "instance_state" {
  description = "Current state of the compute instance."
  value       = oci_core_instance.compute.state
}

output "vcn_id" {
  description = "OCID of the Virtual Cloud Network."
  value       = oci_core_vcn.vcn.id
}

output "subnet_id" {
  description = "OCID of the public subnet."
  value       = oci_core_subnet.public_subnet.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance."
  value       = "ssh opc@${oci_core_instance.compute.public_ip}"
}
