# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying production-grade Azure infrastructure using the HashiCorp azurerm provider.

## Prerequisites

- Terraform >= 1.0.0
- Azure CLI >= 2.40.0
- Azure subscription with required permissions
- Git (for version control)
- VS Code with Terraform extension (recommended)

## Project Structure

```
.
├── modules/                    # Reusable infrastructure modules
│   ├── aad_group/             # Azure AD Group management
│   ├── acr/                   # Azure Container Registry
│   ├── aks/                   # Azure Kubernetes Service
│   ├── bastion/               # Azure Bastion Host
│   ├── keyvault/              # Azure Key Vault
│   ├── log_analytics/         # Log Analytics Workspace
│   ├── network_security_group/# Network Security Groups
│   ├── private_dns_zone/      # Private DNS Zones
│   ├── resource_group/        # Resource Groups
│   ├── storage/               # Azure Storage Accounts
│   ├── subnet/                # Subnet configurations
│   └── virtual_network/       # Virtual Network
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Root module variable declarations
├── terraform.tfvars          # Variable assignments
├── providers.tf              # Provider configurations
└── outputs.tf                # Output declarations
```

## Infrastructure Configuration Standards

### Provider Version Management
```hcl
# Root module provider version constraint (in providers.tf)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # Allows 3.x.x but not 4.0.0
    }
  }
}
```

### Resource Naming Convention
We follow Azure's recommended naming convention:

- Resource Groups: `rg-<environment>-<region>-<workload>`
- Virtual Networks: `vnet-<environment>-<region>-<workload>`
- Subnets: `snet-<environment>-<purpose>`
- AKS Clusters: `aks-<environment>-<region>-<workload>`
- ACR: `acr<environment><workload>` (no hyphens allowed)
- Key Vault: `kv-<environment>-<workload>`
- Storage Account: `st<environment><workload>` (no hyphens allowed)

Example variables in terraform.tfvars:
```hcl
environment = "prod"
region      = "eastus"
workload    = "platform"
```

## Variable Management

### Root Module Variables
Variables are declared in `variables.tf`:
```hcl
variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, dev, staging)"
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"
}
```

### Module Variables
Each module contains its own `variables.tf` with clear type constraints and descriptions.

## Authentication and Initialization

1. Azure Authentication:
```bash
az login
az account set --subscription="SUBSCRIPTION_ID"
```

2. Initialize Terraform:
```bash
terraform init
```

3. Deploy Infrastructure:
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## Module Usage Examples

### Resource Group Module
```hcl
module "resource_group" {
  source = "./modules/resource_group"

  name     = "rg-${var.environment}-${var.location}-${var.workload}"
  location = var.location
  tags     = var.tags
}
```

### Virtual Network Module
```hcl
module "virtual_network" {
  source = "./modules/virtual_network"

  name                = "vnet-${var.environment}-${var.location}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}
```

## Security Best Practices

- All resources are deployed with private endpoints where applicable
- Network security groups with strict inbound/outbound rules
- Key Vault access policies using Azure AD authentication
- RBAC enabled on all resources
- Network isolation using subnets and NSGs
- Regular secret rotation using Key Vault
- Encryption at rest enabled for all supported resources

## State Management

State is stored in Azure Storage with the following features:
- State locking to prevent concurrent modifications
- Encryption at rest
- Access control via Azure AD
- Versioning enabled for rollback capability

## Output Values

Relevant resource information is exposed through outputs.tf, including:
- Resource IDs
- Resource names
- Connection strings (stored in Key Vault)
- API endpoints

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the established conventions
4. Update documentation as needed
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.