variable "gcp_project_id" {
  default = "-225805"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-c"
}
variable "vm_name" {
  default = "gcp_tf_vm"
}
variable "vm_type" {
  default = "n1-standard-1"
}
variable "vm_image" {
  default = "centos-cloud/centos-7"
}
variable "vm_image_type" {
  default = "pd-standard"
}
variable "source_account_email" {
  default = "dummy_source_account_email"
}
variable "metadata_script" {
  default = "initscript_chef.sh"
}
variable "metadata_script_changed" {
  default = "true"
}
variable "creds_file" {
  default = ".keys/account.json"
}
