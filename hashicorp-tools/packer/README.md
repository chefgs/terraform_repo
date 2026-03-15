# Packer – Golden AMI Builder for 2-Tier AWS App

Build hardened, pre-baked Amazon Machine Images (AMIs) for a 2-tier application using **HashiCorp Packer**, with Consul agent and Vault agent pre-installed.

## AMIs Built

| AMI | Purpose | Pre-installed Software |
|-----|---------|----------------------|
| `2tier-web-server` | Web tier (public subnet) | Nginx, Consul agent |
| `2tier-app-server` | App tier (private subnet) | Node.js 20, Consul agent, Vault agent |

## Prerequisites

```bash
# Install Packer
brew install hashicorp/tap/packer   # macOS
# or download from https://developer.hashicorp.com/packer/downloads

# Configure AWS credentials
aws configure --profile default

# Install plugins
packer init ami.pkr.hcl
```

## Build AMIs

```bash
# Validate templates
packer validate ami.pkr.hcl

# Build web server AMI
packer build -only="web-server.*" ami.pkr.hcl

# Build app server AMI
packer build -only="app-server.*" ami.pkr.hcl

# Build all AMIs
packer build ami.pkr.hcl

# Build with custom variables
packer build \
  -var "aws_region=us-west-2" \
  -var "app_version=2.1.0" \
  -var "environment=prod" \
  ami.pkr.hcl
```

## Using Built AMIs in Terraform

After building, reference the AMIs in your Terraform code:

```hcl
data "aws_ami" "web_server" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["2tier-web-server-*"]
  }

  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }
}
```
