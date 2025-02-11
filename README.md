# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying production-grade Azure infrastructure using the HashiCorp azurerm provider.

## Prerequisites

- Terraform >= 4.17.0
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
│   ├── mysql_flexible/        # Azure Database for MySQL Flexible Server
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

## Module Details

Each module follows a consistent structure:
- `main.tf` - Primary resource configurations
- `variables.tf` - Input variable declarations
- `outputs.tf` - Output value definitions
- `README.md` - Module-specific documentation

### Common Module Features
- Consistent tagging support
- Resource naming following Azure conventions
- Optional feature flags
- Dependency handling
- Comprehensive output values

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
We follow Azure's recommended naming convention with standardized prefixes:

| Resource Type | Pattern | Example |
|--------------|---------|---------|
| Resource Groups | `rg-<environment>-<region>-<workload>` | `rg-prod-eastus-platform` |
| Virtual Networks | `vnet-<environment>-<region>-<workload>` | `vnet-prod-eastus-platform` |
| Subnets | `snet-<environment>-<purpose>` | `snet-prod-aks` |
| AKS Clusters | `aks-<environment>-<region>-<workload>` | `aks-prod-eastus-platform` |
| ACR | `acr<environment><workload>` | `acrprodplatform` |
| Key Vault | `kv-<environment>-<workload>` | `kv-prod-platform` |
| Storage Account | `st<environment><workload>` | `stprodplatform` |
| MySQL Flexible | `mysql-flex-<environment>-<workload>` | `mysql-flex-prod-platform` |
| Log Analytics | `log-<environment>-<region>-<workload>` | `log-prod-eastus-platform` |

## Variable Management

### Root Module Variables (variables.tf)
```hcl
variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, dev, staging)"
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
  default     = {}
}
```

### Variable Assignment (terraform.tfvars)
```hcl
environment = "prod"
location    = "eastus"
workload    = "platform"
tags = {
  Environment = "Production"
  Owner       = "Platform Team"
  ManagedBy   = "Terraform"
}
```

## Deployment Process

1. **Authentication**:
   ```bash
   az login
   az account set --subscription="SUBSCRIPTION_ID"
   ```

2. **Workspace Selection**:
   ```bash
   terraform workspace select <environment> || terraform workspace new <environment>
   ```

3. **Configuration Validation**:
   ```bash
   terraform init
   terraform validate
   terraform fmt -check -recursive
   ```

4. **Deployment Planning**:
   ```bash
   terraform plan -out=tfplan
   ```

5. **Infrastructure Application**:
   ```bash
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

State is managed in Azure Storage with these features:
- State file locking (prevents concurrent modifications)
- Encryption at rest (AES-256)
- Access control via Azure AD identities
- Soft delete and versioning enabled
- Regular backups

Example backend configuration:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name      = "tfstate"
    key                 = "prod.terraform.tfstate"
  }
}
```

## Security Considerations

- All sensitive values stored in Key Vault
- Network isolation through NSGs and private endpoints
- RBAC assignments for least-privilege access
- Regular secret rotation policy
- Network security groups with defined security rules
- Service endpoints for Azure PaaS services
- Private DNS zones for private endpoints

## Monitoring and Logging

- Log Analytics workspace for centralized logging
- Diagnostic settings enabled on all supported resources
- Custom metrics and log queries
- Azure Monitor alerts configuration
- Activity logs retention policy

## Output Values

Relevant resource information is exposed through outputs.tf, including:
- Resource IDs
- Resource names
- Connection strings (stored in Key Vault)
- API endpoints

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.