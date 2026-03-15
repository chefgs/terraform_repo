# Getting Started with the Example Provider

This guide provides instructions on how to build and use the Example Terraform provider. The Example provider allows you to manage server resources through Terraform.

## Prerequisites

* [Terraform](https://www.terraform.io/downloads.html) 1.0.0 or later
* [Go](https://golang.org/doc/install) 1.21 or later (to build the provider plugin)

## Building the Provider

1. Clone the repository:

```shell
git clone https://github.com/chefgs/terraform_repo.git
cd terraform_repo/terraform-provider-example
```

2. Build the provider:

```shell
go build -o terraform-provider-example
```

## Installing the Provider

After building the provider, install it in the local Terraform plugin directory:

```shell
mkdir -p ~/.terraform.d/plugins/registry.terraform.io/chefgs/example/1.0.0/$(go env GOOS)_$(go env GOARCH)
cp terraform-provider-example ~/.terraform.d/plugins/registry.terraform.io/chefgs/example/1.0.0/$(go env GOOS)_$(go env GOARCH)/
```

## Using the Provider

To use the provider, create a new Terraform configuration file with the following content:

```hcl
terraform {
  required_providers {
    example = {
      source = "registry.terraform.io/chefgs/example"
    }
  }
}

provider "example" {
  example_setting = "custom_value"
}

resource "example_server" "server" {
  name       = "example-server"
  ip_address = "192.168.1.100"
  port       = 8080
}

output "server_id" {
  value = example_server.server.id
}
```

Initialize your Terraform workspace, which will download the provider:

```shell
terraform init
```

Apply the configuration to create the resources:

```shell
terraform apply
```

To destroy the resources when you're done:

```shell
terraform destroy
```

## Developing the Provider

If you wish to work on the provider, you'll first need [Go](https://golang.org) installed on your machine.

To compile the provider, run `go build`. This will build the provider and put the provider binary in the current directory.

```shell
go build -o terraform-provider-example
```

To run tests, use:

```shell
go test ./...
```

For acceptance tests (which create real resources), set the `TF_ACC` environment variable:

```shell
TF_ACC=1 go test ./... -v
```

## Creating Provider Documentation

The documentation for the Example provider is generated from:

1. The provider and resource schemas (descriptions in the code)
2. Markdown files in the `docs/` directory

To generate provider documentation, first ensure you have the `tfplugindocs` tool installed:

```shell
go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs@latest
```

Then, run the documentation generator:

```shell
tfplugindocs generate
```

This will create or update documentation in the `docs/` directory based on your provider code and existing documentation files.

## Further Reading

* [Example Provider Development Guide](../PROVIDER_DEVELOPMENT.md)
* [Terraform Documentation](https://www.terraform.io/docs/index.html)
* [Terraform Plugin Framework Documentation](https://developer.hashicorp.com/terraform/plugin/framework)
