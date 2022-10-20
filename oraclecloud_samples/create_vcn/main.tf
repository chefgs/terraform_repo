provider "oci" {
  region              = var.region
  auth                = "APIKey"
  config_file_profile = var.profile
}

resource "oci_core_vcn" "internal" {
  dns_label      = "internal"
  cidr_block     = var.cidr_block
  compartment_id = var.compartment_ocid
  display_name   = var.name
}