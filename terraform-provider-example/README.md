# Terraform Provider Development Using Plugin Framework

This is a Terraform provider example built using the Terraform Plugin Framework. It demonstrates how to implement a custom provider with resources using modern Terraform development practices.

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Go](https://golang.org/doc/install) >= 1.21

## Building The Provider

1. Clone the repository
2. Enter the repository directory
3. Build the provider using the `make` command:

```sh
make build
```

## Installing The Provider For Local Testing

After building the provider, install it into Terraform's plugin directory:

```sh
make install
```

This will build and install the provider into your `~/.terraform.d/plugins` directory.

## Using the Provider

To use the provider, create a Terraform configuration file (e.g., `main.tf`) with the following content:

```hcl
terraform {
  required_providers {
    example = {
      source = "registry.terraform.io/chefgs/example"
    }
  }
}

resource "example_server" "my_server" {
  name       = "my-server"
  ip_address = "192.168.1.100"
  port       = 8080
}

output "server_id" {
  value = example_server.my_server.id
}
```

## Developing the Provider

If you wish to contribute to this provider, follow these steps:

1. Ensure you have [Go](https://golang.org/doc/install) installed.
2. Clone the repository.
3. Run `go mod tidy` to ensure dependencies are installed.
4. Make your changes.
5. Run `make build` to build the provider.
6. Use `make install` to install the provider locally for testing.
7. Run `terraform init` in your test configuration directory.

## Provider Resources

The provider currently supports the following resources:

- `example_server`: A resource that represents a server with name, IP address, and port.

## Documentation

This provider includes comprehensive documentation:

- [Provider Configuration](docs/index.md)
- [Server Resource](docs/resources/server.md)
- [Getting Started Guide](docs/guides/getting-started.md)
- [Working with Resources Guide](docs/guides/resource-usage.md)

## Terraform Provider Development Guide

For a comprehensive guide on developing Terraform providers and understanding why and how to create custom providers, see the [Provider Development Guide](PROVIDER_DEVELOPMENT.md). This guide covers:

- Benefits of custom provider development
- Prerequisites and knowledge needed
- Step-by-step implementation instructions
- Best practices and common challenges
- Learning paths for beginners

## License

This project is licensed under the MIT License.