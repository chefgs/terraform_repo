# Create Virtual Cloud Network (VCN) on Oracle Cloud Infrastructure (OCI) using Terraform


### Things required to get started

- [OCI Tenancy](https://www.oracle.com/cloud/free/?intcmp=CloudFree_CTA1_Default&source=:ex:tb:::::RC_WWMK210622P00192:Hashicorp%2BCloudFree_CTA1_Default) Note your region, you will use it throughout the sample.
- The [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/oci-get-started#install-terraform) installed.
- The [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) installed.


### Configure the OCI Terraform provider.

The OCI Terraform provider supports four authentication methods:

- [API Key Authentication](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#APIKeyAuth) (default)
- [Instance Principal Authorization](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#instancePrincipalAuth)
- [Resource Principal Authorization](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#resourcePrincipalAuth)
- [Security Token Authentication](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#securityTokenAuth)

In this example we using API Key Authentication.


### How code works

In this sample we tried to create a sample VCN

- In ``version.tf`` file contains the initial terraform block to define provider we are going to use.

```
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "4.96.0"
    }
  }
}
```

- In ``variables.tf`` we defined our variables 

```
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
  default = "<compartment_ocid>"
}

```

In variables we define profile's default value to ``terraform`` because we set profile with the name of terraform in our oci default config ``~/.oci/config``
like this:

```ini
[terraform]
user=ocid1.user.oc1..aaaaaaaaq...
fingerprint=72:8f:70:ea:db:6a:12:59:e8:13:1c:7e:19:12:25:7a
tenancy=ocid1.tenancy.oc1..aaaaaaaaeeau...
region=ap-mumbai-1
key_file=/home/-10-18-16-19.pem # Change this to your api key path
```

- In ``main.tf`` file we define our provider configuration and VCN resource.

```
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
```

- In ``output.tf`` we output which will give us the ID of newly created VCN.

```
output "vcn_id" {
  value = oci_core_vcn.internal.id
}
```

### Provision resources 

Initialize terraform using ``terraform init`` it will install all required providers which we define in our ``version.tf`` file.

Plan terraform using ``terraform plan`` it will give us the output which will show what resources will be provisioned.

Apply terraform using ``terraform apply`` it will provision actual resources.

Clean up the resources by using ``terraform destroy``
