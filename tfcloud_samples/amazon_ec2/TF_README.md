<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.75.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.app_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | n/a | `number` | `2` | no |
| <a name="input_instance_count_needed"></a> [instance\_count\_needed](#input\_instance\_count\_needed) | n/a | `string` | `"true"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-west-2"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->