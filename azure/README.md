# Azure – Terraform IaC Examples

Terraform code samples for **Microsoft Azure** infrastructure provisioning.

## Directory Structure

```
azure/
└── create-vm/       # Resource group and virtual network creation
```

## Getting Started

### Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- [Terraform CLI](https://developer.hashicorp.com/terraform/install) installed

### Authentication

Authenticate using the Azure CLI:

```bash
az login
```

### Provision Resources

```bash
cd create-vm/
terraform init
terraform plan
terraform apply
```

## Azure Terraform Docs

- [Authenticating to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [Authenticating to Azure using the Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

### Other Azure Authentication Methods

- Authenticating to Azure using Managed Service Identity
- Authenticating to Azure using a Service Principal and a Client Certificate
- Authenticating to Azure using a Service Principal and a Client Secret
- Authenticating to Azure using OpenID Connect