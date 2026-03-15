# Working with Example Provider Resources

This guide provides detailed information on working with resources in the Example provider, including advanced usage patterns, best practices, and troubleshooting tips.

## Resource Lifecycle

The Example provider follows the standard Terraform resource lifecycle:

1. **Create**: When you apply a Terraform configuration that includes an `example_server` resource that doesn't exist yet, Terraform calls the provider's Create function.
2. **Read**: After creation, and during subsequent Terraform operations, the Read function retrieves the current state of the resource.
3. **Update**: When you change resource attributes in your configuration, the Update function is called to modify the existing resource.
4. **Delete**: When you remove a resource from your configuration or run `terraform destroy`, the Delete function is called.

## Best Practices

### Resource Naming

Use a consistent naming convention for your resources. Good naming practices include:

* Descriptive names that indicate the purpose of the resource
* Consistent prefix/suffix patterns for different environments
* Avoiding special characters that might cause issues with APIs

Example:

```hcl
resource "example_server" "web_prod_us_east" {
  name       = "web-prod-us-east-1"
  ip_address = "192.168.1.100"
  port       = 80
}
```

### Resource Organization

Organize your resources by function and environment:

```hcl
# Production Web Servers
resource "example_server" "web_prod" {
  count      = 3
  name       = "web-prod-${count.index + 1}"
  ip_address = "192.168.1.${count.index + 100}"
  port       = 80
}

# Development Web Servers
resource "example_server" "web_dev" {
  count      = 1
  name       = "web-dev-${count.index + 1}"
  ip_address = "192.168.2.${count.index + 100}"
  port       = 8080
}
```

### Using Variables

Parameterize your configurations with variables for maximum flexibility:

```hcl
variable "environment" {
  description = "The deployment environment (e.g., prod, dev, staging)"
  type        = string
  default     = "dev"
}

variable "server_count" {
  description = "Number of servers to deploy"
  type        = number
  default     = 1
}

resource "example_server" "web" {
  count      = var.server_count
  name       = "web-${var.environment}-${count.index + 1}"
  ip_address = "192.168.1.${count.index + 100}"
  port       = var.environment == "prod" ? 80 : 8080
}
```

## Advanced Resource Configurations

### Using `for_each` with Maps

The `for_each` meta-argument allows you to create multiple resource instances according to a map or a set of strings:

```hcl
variable "servers" {
  description = "Map of server details"
  type        = map(object({
    ip_address = string
    port       = number
  }))
  default     = {
    "web-1" = {
      ip_address = "192.168.1.101"
      port       = 80
    },
    "api-1" = {
      ip_address = "192.168.1.102"
      port       = 8080
    }
  }
}

resource "example_server" "servers" {
  for_each   = var.servers
  name       = each.key
  ip_address = each.value.ip_address
  port       = each.value.port
}
```

### Conditional Creation with `count`

Use the `count` meta-argument to conditionally create resources:

```hcl
variable "create_server" {
  description = "Whether to create the server"
  type        = bool
  default     = true
}

resource "example_server" "conditional" {
  count      = var.create_server ? 1 : 0
  name       = "conditional-server"
  ip_address = "192.168.1.100"
  port       = 80
}
```

## Troubleshooting

### Common Issues

#### Resource Creation Fails

If resource creation fails, check:

1. The error message in the Terraform output
2. Ensure the IP address is valid
3. Verify the port number is within the valid range (1-65535)

#### State Drift

If you're experiencing state drift (where Terraform's state doesn't match reality):

1. Run `terraform refresh` to update the state
2. Check if resources were modified outside of Terraform
3. Verify your Read function is properly updating the resource state

#### Import Errors

When importing existing resources:

1. Ensure the resource ID format is correct
2. Verify the resource actually exists
3. Check that you have appropriate permissions

### Debugging

Enable verbose logging to help diagnose issues:

```shell
export TF_LOG=DEBUG
terraform apply
```

To capture logs to a file:

```shell
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply
```

## Resource Lifecycle Management

### Preventing Accidental Deletion

Use the `prevent_destroy` lifecycle meta-argument to prevent accidental deletion of critical resources:

```hcl
resource "example_server" "critical" {
  name       = "critical-server"
  ip_address = "192.168.1.100"
  port       = 80
  
  lifecycle {
    prevent_destroy = true
  }
}
```

### Creating Before Destroying

When replacing resources, you can ensure the new resource is created before the old one is destroyed:

```hcl
resource "example_server" "web" {
  name       = "web-server"
  ip_address = "192.168.1.100"
  port       = 80
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### Ignoring Changes

To prevent Terraform from attempting to update certain attributes:

```hcl
resource "example_server" "app" {
  name       = "app-server"
  ip_address = "192.168.1.100"
  port       = 80
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to port (maybe it's managed by another process)
      port,
    ]
  }
}
```

## Next Steps

Now that you understand how to work with Example provider resources, you may want to:

* Explore more complex resource configurations
* Integrate with other providers
* Set up a CI/CD pipeline for your Terraform configurations
* Contribute to the Example provider development
