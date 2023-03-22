<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 4.96.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 4.96.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_vcn.internal](https://registry.terraform.io/providers/oracle/oci/4.96.0/docs/resources/core_vcn) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | n/a | `string` | `"172.16.0.0/20"` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | n/a | `string` | `"ocid1.compartment.oc1..aaaaaaaa2aidpy77drcfgzqgbpg4fdbnrvo34hdabqaldzrfm7zcdxai56jq"` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"terraformVCN"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | n/a | `string` | `"terraform"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"ap-mumbai-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | n/a |
<!-- END_TF_DOCS -->