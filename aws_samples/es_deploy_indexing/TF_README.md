<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticsearch_domain.es](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | AWS access key | `string` | `"A************Q"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account id | `string` | `"123456789876"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Elastic search domain name | `string` | `"gs-demo-es"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of the ES | `string` | `"us-west-2"` | no |
| <a name="input_secret"></a> [secret](#input\_secret) | AWS secret key | `string` | `"u************s"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->