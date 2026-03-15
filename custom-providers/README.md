# Custom Terraform Providers

Examples and guides for **developing custom Terraform providers** in Go.

## Directory Structure

```
custom-providers/
├── basic/           # Basic custom provider (SDK v1 style)
├── updated/         # Updated provider patterns
├── sdk-v2/          # Provider using Terraform Plugin SDK v2
├── example-provider/ # Complete example provider with tests
└── hashicups-pf/    # HashiCups provider (Terraform Plugin Framework)
```

## Provider Development Path

```
1. basic/         → Learn the foundational concepts
2. sdk-v2/        → Modern SDK v2 approach
3. hashicups-pf/  → Latest Plugin Framework approach (recommended)
4. example-provider/ → Production-quality example with docs & tests
```

## Prerequisites

| Tool | Version |
|------|---------|
| Go | >= 1.21 |
| Terraform | >= 1.0 |
| goreleaser | For cross-platform builds |

## Quick Start

```bash
cd hashicups-pf/
go mod download
make build
make test
```
