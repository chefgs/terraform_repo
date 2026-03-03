---
layout: default
title: Custom Providers
nav_order: 6
---

# Custom Terraform Provider Development

This section explains how to build your own Terraform provider from scratch. The repository includes three examples that progressively cover different SDK versions and approaches.

---

## Table of Contents

- [Why Build a Custom Provider?](#why-build-a-custom-provider)
- [Provider Examples in This Repo](#provider-examples-in-this-repo)
- [Provider SDK v1 Example](#provider-sdk-v1-example)
- [Provider SDK v2 Example](#provider-sdk-v2-example)
- [Plugin Framework (HashiCups) Example](#plugin-framework-hashicups-example)
- [Provider Architecture](#provider-architecture)
- [Building and Testing Your Provider](#building-and-testing-your-provider)

---

## Why Build a Custom Provider?

According to the [HashiCorp documentation](https://www.terraform.io/docs/extend/writing-custom-providers.html), there are several valid reasons to build a custom Terraform provider:

1. **Private/internal cloud** — Your infrastructure uses a proprietary API that isn't publicly available
2. **Work in progress** — Testing a new provider locally before contributing to the open-source community
3. **Extending an existing provider** — Adding resources or data sources not yet supported by an official provider
4. **Learning** — Understanding how Terraform's provider plugin system works

---

## Provider Examples in This Repo

| Directory | SDK Version | Description |
|-----------|------------|-------------|
| `custom_provider/tf_custom_provider/` | SDK v1 | Basic custom provider with mock resource |
| `custom_provider/tf_custom_provider_sdkv2/` | SDK v2 | Updated provider using the current SDK |
| `custom_provider/tf_custom_provider_new/` | Latest | Extended patterns and improvements |
| `terraform-provider-example/` | SDK v1/v2 | Standalone provider example |
| `terraform-provider-hashicups-pf/` | Plugin Framework | Official HashiCorp tutorial provider |

---

## Provider SDK v1 Example

**Path:** `custom_provider/tf_custom_provider/`

### File Structure

```
tf_custom_provider/
├── main.go              # Go entry point
├── provider.go          # Provider definition and resource registration
├── resource_server.go   # Resource CRUD operations
├── main.tf              # Terraform configuration to test the provider
└── go.mod               # Go module definition
```

### How It Works

#### 1. `main.go` — Entry Point

```go
package main

import (
    "github.com/hashicorp/terraform-plugin-sdk/plugin"
    "github.com/hashicorp/terraform-plugin-sdk/terraform"
)

func main() {
    plugin.Serve(&plugin.ServeOpts{
        ProviderFunc: func() terraform.ResourceProvider {
            return Provider()
        },
    })
}
```

#### 2. `provider.go` — Provider Definition

```go
func Provider() *schema.Provider {
    return &schema.Provider{
        ResourcesMap: map[string]*schema.Resource{
            "customprovider_server": resourceServer(),
        },
    }
}
```

#### 3. `resource_server.go` — Resource Definition

```go
func resourceServer() *schema.Resource {
    return &schema.Resource{
        Create: resourceServerCreate,
        Read:   resourceServerRead,
        Update: resourceServerUpdate,
        Delete: resourceServerDelete,
        Schema: map[string]*schema.Schema{
            "server_count": {
                Type:     schema.TypeInt,
                Required: true,
            },
        },
    }
}

func resourceServerCreate(d *schema.ResourceData, m interface{}) error {
    count := d.Get("server_count").(int)
    d.SetId(fmt.Sprintf("server-%d", count))
    return nil
}
```

#### 4. `main.tf` — Using the Custom Provider

```hcl
terraform {
  required_providers {
    customprovider = {
      source  = "local/customprovider"
      version = "~> 1.0"
    }
  }
}

provider "customprovider" {}

resource "customprovider_server" "example" {
  server_count = 3
}
```

---

## Provider SDK v2 Example

**Path:** `custom_provider/tf_custom_provider_sdkv2/`

The Terraform Plugin SDK v2 is the current recommended SDK for building providers. Key improvements over v1:

- Better diagnostics and error reporting
- Improved testing framework
- Context-aware CRUD functions
- Better support for complex types

### SDK v2 Resource Function Signature

```go
// SDK v1 (old)
func resourceServerCreate(d *schema.ResourceData, m interface{}) error

// SDK v2 (new) - context-aware
func resourceServerCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics
```

### SDK v2 Provider Example

```go
package main

import (
    "context"
    "github.com/hashicorp/terraform-plugin-sdk/v2/diag"
    "github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
    "github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
)

func main() {
    plugin.Serve(&plugin.ServeOpts{
        ProviderFunc: provider,
    })
}

func provider() *schema.Provider {
    return &schema.Provider{
        ResourcesMap: map[string]*schema.Resource{
            "customprovider_server": resourceServer(),
        },
    }
}

func resourceServer() *schema.Resource {
    return &schema.Resource{
        CreateContext: resourceServerCreate,
        ReadContext:   resourceServerRead,
        DeleteContext: resourceServerDelete,
        Schema: map[string]*schema.Schema{
            "server_count": {
                Type:     schema.TypeInt,
                Required: true,
                ForceNew: true,
            },
        },
    }
}

func resourceServerCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
    count := d.Get("server_count").(int)
    d.SetId(fmt.Sprintf("server-%d", count))
    return nil
}
```

---

## Plugin Framework (HashiCups) Example

**Path:** `terraform-provider-hashicups-pf/`

The [Terraform Plugin Framework](https://developer.hashicorp.com/terraform/plugin/framework) is the newest and recommended approach for building providers. It uses a different, more Go-idiomatic API.

### Plugin Framework vs SDK v2

| Feature | SDK v2 | Plugin Framework |
|---------|--------|-----------------|
| API style | Schema-based | Interface-based |
| Type safety | Limited | Strong |
| Diagnostics | `diag.Diagnostics` | `diag.Diagnostics` |
| Recommended | For existing providers | For new providers |
| Testing | `resource.Test` | `resource.Test` |

### Plugin Framework Provider Structure

```go
// provider.go
type hashicupsProvider struct {
    version string
}

func (p *hashicupsProvider) Metadata(ctx context.Context, req provider.MetadataRequest, resp *provider.MetadataResponse) {
    resp.TypeName = "hashicups"
    resp.Version = p.version
}

func (p *hashicupsProvider) Schema(ctx context.Context, req provider.SchemaRequest, resp *provider.SchemaResponse) {
    resp.Schema = schema.Schema{
        Attributes: map[string]schema.Attribute{
            "host": schema.StringAttribute{
                Optional: true,
            },
            "username": schema.StringAttribute{
                Optional:  true,
                Sensitive: true,
            },
        },
    }
}
```

---

## Provider Architecture

All Terraform providers follow this architecture:

```
┌─────────────────────────────────────────────┐
│               Terraform Core                │
│  (terraform init / plan / apply / destroy)  │
└──────────────────┬──────────────────────────┘
                   │ gRPC / plugin protocol
┌──────────────────▼──────────────────────────┐
│           Terraform Provider Binary         │
│  ┌──────────────────────────────────────┐   │
│  │            Provider Schema           │   │
│  │  (authentication, configuration)     │   │
│  └──────────────────────────────────────┘   │
│  ┌──────────────────────────────────────┐   │
│  │           Resource CRUD              │   │
│  │  Create / Read / Update / Delete     │   │
│  └──────────────────────────────────────┘   │
│  ┌──────────────────────────────────────┐   │
│  │           Data Sources               │   │
│  │  (read-only lookups)                 │   │
│  └──────────────────────────────────────┘   │
└──────────────────┬──────────────────────────┘
                   │ API calls
┌──────────────────▼──────────────────────────┐
│           Target API / Service              │
│  (cloud API, internal service, etc.)        │
└─────────────────────────────────────────────┘
```

---

## Building and Testing Your Provider

### Prerequisites

```bash
# Install Go
wget https://dl.google.com/go/go1.21.0.linux-amd64.tar.gz
tar -C /usr/local -xvzf go1.21.0.linux-amd64.tar.gz

# Add to PATH
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

go version
```

### Build the Provider

```bash
cd custom_provider/tf_custom_provider_sdkv2/

# Initialize Go modules
go mod init
go mod tidy

# Build the provider binary
go build -o terraform-provider-customprovider
```

### Install the Provider Locally

```bash
# Linux/macOS
mkdir -p ~/.terraform.d/plugins/local/customprovider/1.0.0/linux_amd64/
cp terraform-provider-customprovider ~/.terraform.d/plugins/local/customprovider/1.0.0/linux_amd64/

# Windows
# Copy to %APPDATA%\terraform.d\plugins\
```

### Test with Terraform

```bash
# Initialize (uses the local plugin)
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy
```

### Running Acceptance Tests

```bash
# Set the provider's test flag
export TF_ACC=1

# Run all tests
go test ./...

# Run specific tests
go test -v -run TestAccServer ./...
```

---

## References

- [Writing Custom Providers - HashiCorp Docs](https://developer.hashicorp.com/terraform/plugin/sdkv2/guides/v2-upgrade-guide)
- [Terraform Plugin Framework](https://developer.hashicorp.com/terraform/plugin/framework)
- [Plugin SDK v2](https://github.com/hashicorp/terraform-plugin-sdk)
- [HashiCorp Learn: Provider Development](https://developer.hashicorp.com/terraform/tutorials/providers-plugin-framework)
- [Terraform Registry - Publishing Providers](https://developer.hashicorp.com/terraform/registry/providers/publishing)

---

*[← Back to GitHub Actions](./github-actions)* | *[Next: Terraform Cloud →](./terraform-cloud)*
