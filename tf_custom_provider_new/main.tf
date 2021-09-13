terraform {
  required_providers {
    example = {
      version = "~> 1.0.0"
      source  = "terraform-example.com/exampleprovider/customprovider"
    }
  }
}

resource "customprovider_server" "my-server-name" {
	uuid_count = "2"
}
