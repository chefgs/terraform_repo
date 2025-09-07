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

output "server_ip" {
  value = example_server.my_server.ip_address
}