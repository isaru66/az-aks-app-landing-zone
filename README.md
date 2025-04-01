# Azure Application AKS Landing Zone with Terraform

This repository contains Terraform configurations for deploying production-grade Azure infrastructure using the HashiCorp azurerm provider.

## Prerequisites

- Terraform >= 4.1.7
- Azure CLI >= 2.40.0
- Azure subscription with required permissions
- Git (for version control)
- VS Code with Terraform extension (recommended)

## Project Structure

```
.
├── modules/                    # Reusable infrastructure modules
│   ├── aad_group/              # Azure AD Group management
│   ├── acr/                    # Azure Container Registry
│   ├── aks/                    # Azure Kubernetes Service
│   ├── bastion/                # Azure Bastion Host
│   ├── keyvault/               # Azure Key Vault
│   ├── linux_vm/               # Linux Virtual Machines
│   ├── log_analytics/          # Log Analytics Workspace
│   ├── mysql_flexible/         # Azure Database for MySQL Flexible Server
│   ├── network_security_group/ # Network Security Groups
│   ├── private_dns_zone/       # Private DNS Zones
│   ├── resource_group/         # Resource Groups
│   ├── storage/                # Azure Storage Accounts
│   ├── subnet/                 # Subnet configurations
│   └── virtual_network/        # Virtual Network
├── main.tf                     # Main infrastructure configuration
├── variables.tf                # Root module variable declarations
├── terraform.tfvars            # Variable assignments
├── providers.tf                # Provider configurations
└── outputs.tf                  # Output declarations
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
  required_version = ">= 1.0.0"
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
| Network Security Groups | `nsg-<environment>-<purpose>` | `nsg-prod-app` |
| Public IP | `pip-<environment>-<purpose>` | `pip-prod-bastion` |
| Linux VM | `vm-<environment>-<workload>` | `vm-prod-jumpbox` |
| Bastion Host | `bas-<environment>-<region>` | `bas-prod-eastus` |

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
   ```

4. **Deployment Planning**:
   ```bash
   terraform plan
   ```

5. **Infrastructure Application**:
   ```bash
   terraform apply
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
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
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

## GitHub Copilot Demo

This project is set up to demonstrate how GitHub Copilot can enhance your Terraform development workflow. Below are examples of how to leverage Copilot for your Azure infrastructure projects:

### Demo Scenarios

1. **Module Creation**: Use Copilot to generate new Azure resource modules
2. **Variable Definition**: Generate comprehensive variable definitions with proper types and descriptions
3. **Resource Configuration**: Write complex resource configurations with best practices applied
4. **Documentation**: Create or enhance module README files and comments
5. **HCL Syntax Assistance**: Leverage Copilot for complex HCL syntax like dynamic blocks and for_each

### Using Copilot with This Project

#### Creating a New Module

To use GitHub Copilot to create a new module:

1. Create a new directory under `modules/` for your resource type
2. Initialize the required files (main.tf, variables.tf, outputs.tf, README.md)
3. Start typing comments describing what you want, for example:
   ```hcl
   # Create an Azure App Service module with the following features:
   # - Support for app service plan configuration
   # - Integration with virtual network
   # - Support for custom app settings
   # - System-assigned managed identity
   ```
4. Let Copilot suggest the implementation based on your comments

#### Enhancing Existing Modules

Copilot can help enhance existing modules:

1. Add descriptive comments about what you want to add or modify
2. For example, type: `# Add support for private endpoints to this storage account module`
3. Copilot will suggest the appropriate resources and configurations

#### Writing Terraform Variables

Copilot can help create well-documented variables:

```hcl
# Define a variable for controlling the SKU of the Azure Key Vault
```

#### Generating Resource Blocks

Copilot can create complex resource blocks based on your intent:

```hcl
# Create an Azure Container Registry with geo-replication, private endpoints, and RBAC
```

## Creating New Modules

When creating new modules for this project, follow these guidelines to ensure consistency:

### Module Structure Template

```
modules/new_module/
├── main.tf           # Primary resource configuration
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output definitions
└── README.md         # Module documentation
```

### Required Files and Contents

1. **main.tf**:
   ```hcl
   # Azure [Resource Type] Module
   # This module deploys [resource description]

   resource "azurerm_[resource_type]" "this" {
     name                = var.name
     resource_group_name = var.resource_group_name
     location            = var.location
     
     # Resource-specific properties
     
     tags = var.tags
   }
   ```

2. **variables.tf**:
   ```hcl
   variable "name" {
     description = "The name of the resource"
     type        = string
   }

   variable "resource_group_name" {
     description = "The name of the resource group"
     type        = string
   }

   variable "location" {
     description = "The Azure region where the resource should be created"
     type        = string
   }

   variable "tags" {
     description = "A map of tags to assign to the resources"
     type        = map(string)
     default     = {}
   }

   # Resource-specific variables
   ```

3. **outputs.tf**:
   ```hcl
   output "id" {
     description = "The ID of the created resource"
     value       = azurerm_[resource_type].this.id
   }

   output "name" {
     description = "The name of the created resource"
     value       = azurerm_[resource_type].this.name
   }

   # Resource-specific outputs
   ```

4. **README.md**:
   ```markdown
   # Azure [Resource Type] Module

   This module deploys [resource description].

   ## Usage

   ```hcl
   module "[resource_type]" {
     source              = "./modules/[resource_type]"
     name                = "example-name"
     resource_group_name = "example-rg"
     location            = "eastus"
     
     # Resource-specific arguments
     
     tags = {
       Environment = "Production"
     }
   }
   ```

   ## Required Arguments

   * `name` - (Required) The name of the resource
   * `resource_group_name` - (Required) The name of the resource group
   * `location` - (Required) The Azure region where the resource should be created

   ## Optional Arguments

   * `tags` - (Optional) A map of tags to assign to the resources

   ## Outputs

   * `id` - The ID of the created resource
   * `name` - The name of the created resource
   ```

### Best Practices for New Modules

1. **Naming Convention**: Follow the project's established naming patterns
2. **Feature Flags**: Use boolean variables for optional features
3. **Validation**: Add variable validation for critical inputs
4. **Dependencies**: Use explicit depends_on for critical dependencies
5. **Documentation**: Document all inputs, outputs, and examples
6. **Tagging**: Support consistent tagging across all resources
7. **Dynamic Blocks**: Use for repetitive nested configurations
8. **Error Handling**: Use count or for_each conditionals for optional resources

## Environment Configuration

This project uses environment-specific configuration files stored in the `environments/` directory:

```
environments/
├── dev.tfvars       # Development environment variables
├── staging.tfvars   # Staging environment variables
└── prod.tfvars      # Production environment variables
```

To deploy to a specific environment:

```bash
terraform apply -var-file=environments/dev.tfvars
```
