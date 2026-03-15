# example_server Resource

Provides an Example server resource. This allows servers to be created, updated, and deleted.

## Example Usage

```hcl
resource "example_server" "web" {
  name       = "web-server-01"
  ip_address = "192.168.1.100"
  port       = 8080
}
```

## Argument Reference

The following arguments are supported:

* `name` - (Required) The name of the server.
* `ip_address` - (Required) The IP address of the server.
* `port` - (Optional) The port number the server will use. Defaults to `80`.

## Attributes Reference

In addition to all arguments above, the following attributes are exported:

* `id` - The ID of the server.

## Import

Example servers can be imported using the `id`, e.g.,

```shell
terraform import example_server.web server-web-server-01
```

## Timeouts

The `example_server` resource provides the following
[Timeouts](https://www.terraform.io/docs/configuration/blocks/resources/syntax.html#operation-timeouts) configuration options:

* `create` - (Default `30 minutes`) Used when creating the server
* `update` - (Default `30 minutes`) Used when updating the server
* `delete` - (Default `30 minutes`) Used when destroying the server

## Nested Blocks

### Example Configuration Block

The configuration block supports the following:

```hcl
resource "example_server" "web" {
  name       = "web-server-01"
  ip_address = "192.168.1.100"
  port       = 8080
  
  # Example of a nested configuration block (not implemented in our example provider)
  config {
    monitoring = true
    backup     = true
  }
  
  tags = {
    Environment = "Production"
    Owner       = "DevOps Team"
  }
}
```

## Advanced Usage Examples

### Load Balancer Configuration

```hcl
# Create a group of servers
resource "example_server" "web_cluster" {
  count      = 3
  name       = "web-server-${count.index + 1}"
  ip_address = "192.168.1.${count.index + 100}"
  port       = 8080
}

# Output the IPs of all servers (not implemented in our example provider)
output "web_server_ips" {
  value = example_server.web_cluster[*].ip_address
}
```

### Using with Other Resources

```hcl
# Create a server
resource "example_server" "app" {
  name       = "app-server-01"
  ip_address = "192.168.1.200"
  port       = 8080
}

# Example of connecting to another resource (not implemented in our example provider)
resource "example_database" "db" {
  name       = "app-database"
  server_id  = example_server.app.id
  engine     = "postgres"
  engine_version = "13"
}
```
