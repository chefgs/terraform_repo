variable "profile" {
  type = string
  default = "terraform"
}

variable "region" {
  type = string
  default = "ap-mumbai-1"
}

variable "name" {
  type = string
  default = "terraformVCN"
}

variable "cidr_block" {
  type = string
  default = "172.16.0.0/20"
}

variable "compartment_ocid" {
  type = string
  default = "ocid1.compartment.oc1..aaaaaaaa2aidpy77drcfgzqgbpg4fdbnrvo34hdabqaldzrfm7zcdxai56jq"
}
