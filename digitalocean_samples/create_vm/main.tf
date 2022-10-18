provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

resource "digitalocean_droplet" "droplet" {
  image  = var.image
  name   = var.name
  region = var.region
  size   = var.size
  ssh_keys = [ 
    data.digitalocean_ssh_key.terraform.id
   ]
  tags = [ "Terraform", var.env ]
}