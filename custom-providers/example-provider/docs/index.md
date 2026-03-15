# Example Provider Documentation

The Example provider is used to interact with the resources supported by Example API. The provider needs to be configured with proper credentials before it can be used.

Use the navigation to the left to read about the available resources.

## Example Usage

```hcl
# Configure the Example Provider
terraform {
  required_providers {
    example = {
      source  = "chefgs/example"
      version = "~> 1.0"
    }
  }
}

provider "example" {
  example_setting = "custom_value"
}

# Create an Example Server
resource "example_server" "server" {
  name       = "web-server-01"
  ip_address = "192.168.1.100"
  port       = 8080
}
```

## Authentication

The Example provider offers a flexible means of providing credentials for authentication. The following methods are supported, listed in order of precedence:

1. Provider block
2. Environment variables
3. Shared credentials file

### Provider Block

You can provide your credentials directly in the provider block:

```hcl
provider "example" {
  example_setting = "custom_value"
}
```

### Environment Variables

You can provide your credentials via the `EXAMPLE_SETTING` environment variable:

```sh
export EXAMPLE_SETTING="custom_value"
```

```hcl
provider "example" {}
```

### Shared Credentials File

You can use a shared credentials file. For example:

```hcl
provider "example" {
  shared_credentials_file = "/path/to/credentials"
}
```

## Argument Reference

The following arguments are supported in the provider block:

* `example_setting` - (Optional) This is an example setting. It can also be sourced from the `EXAMPLE_SETTING` environment variable.
* `shared_credentials_file` - (Optional) Path to a shared credentials file. Can also be sourced from the `EXAMPLE_SHARED_CREDENTIALS_FILE` environment variable.

## Debugging

Terraform has detailed logs which can be enabled by setting the `TF_LOG` environment variable to any value. This causes detailed logs to appear on stderr.

Additionally, the `TF_LOG_PATH` environment variable can be set to provide a persistent log file for debugging purposes:

```sh
export TF_LOG=TRACE
export TF_LOG_PATH=./terraform.log
```
