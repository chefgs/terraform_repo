## Terraform Cloud Sample

### How this works
- Terraform cloud runs the `terraform apply` run in Terraform Cloud workspace, since we have declared the terraform cloud as a remote backend in the code.
- We need to configure Terraform source code path in the `Settings > General` page for the given workspace in Terraform Cloud
- Change the Terraform Working Directory setting to specify the path of the config, relative to the relevant root directory - in this case: `tfcloud_samples/amazon_ec2`
- In case of variable override, add the variables into `variables` section in Teraform cloud workspace. Otherwise declare `*.auto.tfvars` file.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.76.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instances"></a> [ec2\_instances](#module\_ec2\_instances) | ../modules/aws_two_tier | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_instance.app_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | Variables Block Common values used across the terraform code can be added as variables We can override the values using .tfvars files while running terraform plan/apply | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the EC2 instance(s) |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | State of the EC2 instance(s) |
<!-- END_TF_DOCS -->