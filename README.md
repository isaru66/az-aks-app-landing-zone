# Azure Infrastructure with Terraform

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
│   ├── aad_group/             # Azure AD Group management
│   ├── acr/                   # Azure Container Registry
│   ├── aks/                   # Azure Kubernetes Service
│   ├── bastion/               # Azure Bastion Host
│   ├── keyvault/              # Azure Key Vault
│   ├── linux_vm/              # Linux Virtual Machines
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
├── terraform.tfvars           # Variable assignments
├── providers.tf               # Provider configurations
└── outputs.tf                 # Output declarations
```

## Module Details

Each module follows a consistent structure:
- `main.tf` - Primary resource configurations
- `variables.tf` - Input variable declarations
- `outputs.tf` - Output value definitions
- `README.md` - Module-specific documentation

### Detailed Module Documentation

#### Resource Group Module
Manages the creation and lifecycle of Azure Resource Groups.
```hcl
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "rg-${var.environment}-${var.location}-${var.workload}"
  location = var.location
  tags     = var.tags
}
```

#### Virtual Network Module
Deploys Azure Virtual Networks with customizable address spaces.
```hcl
module "virtual_network" {
  source              = "./modules/virtual_network"
  name                = "vnet-${var.environment}-${var.location}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
  dns_servers         = optional(["168.63.129.16"])
}
```

#### Subnet Module
Creates and manages subnets within a virtual network.
```hcl
module "subnet" {
  source               = "./modules/subnet"
  name                 = "snet-${var.environment}-${var.purpose}"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = optional(["Microsoft.KeyVault", "Microsoft.Storage"])
  
  # Optional delegation configuration
  delegation = optional({
    name = "delegation"
    service_delegation = {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  })
}
```

#### Network Security Group Module
Provides network-level security with customizable rules.
```hcl
module "network_security_group" {
  source              = "./modules/network_security_group"
  name                = "nsg-${var.environment}-${var.purpose}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  security_rules = [
    {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  
  # Optional subnet association
  subnet_id = optional(module.subnet.id)
}
```

#### AKS Module
Deploys Azure Kubernetes Service clusters with comprehensive configuration options.
```hcl
module "aks" {
  source              = "./modules/aks"
  name                = "aks-${var.environment}-${var.location}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags
  
  default_node_pool = {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id      = module.subnet.id
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
  }
  
  identity = {
    type = "SystemAssigned"
  }
  
  network_profile = {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
  }
}
```

#### ACR Module
Creates Azure Container Registry with optional geo-replication.
```hcl
module "acr" {
  source              = "./modules/acr"
  name                = "acr${var.environment}${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  sku                 = "Premium"
  admin_enabled       = false
  
  # Optional geo-replication
  georeplication_locations = optional(["eastus2", "westus2"])
  
  # Optional private link configuration
  private_endpoint = optional({
    subnet_id            = module.subnet.id
    private_dns_zone_ids = [module.private_dns_zone.id]
  })
}
```

#### Key Vault Module
Manages secure storage for secrets, certificates, and keys.
```hcl
module "keyvault" {
  source              = "./modules/keyvault"
  name                = "kv-${var.environment}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  sku_name                 = "premium"
  enabled_for_deployment   = true
  purge_protection_enabled = true
  
  network_acls = optional({
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["123.123.123.123/32"]
    virtual_network_subnet_ids = [module.subnet.id]
  })
  
  access_policies = [
    {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id
      
      key_permissions = [
        "Get", "List", "Create", "Delete"
      ]
      secret_permissions = [
        "Get", "List", "Set", "Delete"
      ]
      certificate_permissions = [
        "Get", "List", "Create", "Delete"
      ]
    }
  ]
}
```

#### MySQL Flexible Server Module
Deploys Azure Database for MySQL Flexible Server instances.
```hcl
module "mysql_flexible" {
  source              = "./modules/mysql_flexible"
  name                = "mysql-flex-${var.environment}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  
  sku_name   = "GP_Standard_D2ds_v4"
  storage_mb = 32768
  version    = "8.0.21"
  
  backup_retention_days = 7
  geo_redundant_backup  = false
  
  private_dns_zone_id = optional(module.private_dns_zone.id)
  delegated_subnet_id = optional(module.subnet.id)
}
```

#### Log Analytics Module
Sets up centralized logging and monitoring.
```hcl
module "log_analytics" {
  source              = "./modules/log_analytics"
  name                = "log-${var.environment}-${var.location}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  sku               = "PerGB2018"
  retention_in_days = 30
  
  # Optional solutions to enable
  solutions = optional([
    {
      solution_name = "ContainerInsights"
      publisher     = "Microsoft"
      product       = "OMSGallery/ContainerInsights"
    },
    {
      solution_name = "SecurityInsights"
      publisher     = "Microsoft"
      product       = "OMSGallery/SecurityInsights"
    }
  ])
}
```

#### Storage Account Module
Creates Azure Storage Accounts with configurable access tiers and replication.
```hcl
module "storage" {
  source              = "./modules/storage"
  name                = "st${var.environment}${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  
  # Enable hierarchical namespace for Data Lake Storage Gen2
  is_hns_enabled = optional(true)
  
  # Optional network rules
  network_rules = optional({
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = ["123.123.123.123"]
    virtual_network_subnet_ids = [module.subnet.id]
  })
  
  # Optional blob properties
  blob_properties = optional({
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    delete_retention_days    = 7
  })
}
```

#### Private DNS Zone Module
Manages private DNS zones for Azure private endpoints.
```hcl
module "private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = module.resource_group.name
  tags                = var.tags
  
  # Optional virtual network link
  virtual_network_link = optional({
    name                  = "vnet-link"
    virtual_network_id    = module.virtual_network.id
    registration_enabled  = false
  })
}
```

#### Linux VM Module
Deploys Linux virtual machines with customizable configurations.
```hcl
module "linux_vm" {
  source              = "./modules/linux_vm"
  name                = "vm-${var.environment}-${var.workload}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  size                  = "Standard_DS1_v2"
  admin_username        = var.vm_admin_username
  admin_ssh_key_path    = var.vm_admin_ssh_public_key_path
  
  network_interface = {
    name      = "nic-${var.environment}-${var.workload}"
    subnet_id = module.subnet.id
  }
  
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }
  
  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
```

#### Azure Bastion Module
Creates secure access to VMs without exposing public endpoints.
```hcl
module "bastion" {
  source              = "./modules/bastion"
  name                = "bas-${var.environment}-${var.location}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
  
  # Requires a dedicated subnet with name AzureBastionSubnet
  subnet_id = module.subnet.id
  
  # Optional SKU configuration
  sku = optional("Standard")  # Basic or Standard
  
  # Optional IP configuration
  public_ip_name = optional("pip-bastion-${var.environment}-${var.location}")
  public_ip_allocation_method = optional("Static")
  public_ip_sku = optional("Standard")
}
```

#### AAD Group Module
Manages Azure Active Directory groups for RBAC.
```hcl
module "aad_group" {
  source = "./modules/aad_group"
  
  name        = "sg-${var.environment}-${var.workload}-admins"
  description = "Administrator group for ${var.workload} in ${var.environment} environment"
  
  # Optional members
  members = optional([
    "object-id-1",
    "object-id-2"
  ])
  
  # Optional owners
  owners = optional([
    "object-id-3"
  ])
}
```

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

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
```

Note: In submodules, we avoid specifying provider versions to prevent conflicts with the root module.

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

## Variable Management

### Root Module Variables (variables.tf)

All input variables are declared in the variables.tf file with proper descriptions, types, and default values where appropriate:

```hcl
variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, dev, staging)"
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"
}

variable "workload" {
  type        = string
  description = "Workload name or application identifier"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
  default     = {}
}

# Resource-specific variables
variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for AKS cluster"
  default     = "1.25.6"
}

variable "vm_admin_username" {
  type        = string
  description = "Admin username for Linux VMs"
  sensitive   = true
}

variable "vm_admin_ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key file for Linux VM authentication"
}

variable "mysql_admin_username" {
  type        = string
  description = "Admin username for MySQL Flexible Server"
  sensitive   = true
}

variable "mysql_admin_password" {
  type        = string
  description = "Admin password for MySQL Flexible Server"
  sensitive   = true
}
```

### Variable Assignment (terraform.tfvars)

```hcl
# Environment settings
environment = "prod"
location    = "eastus"
workload    = "platform"

# Common tags
tags = {
  Environment     = "Production"
  Owner           = "Platform Team"
  ManagedBy       = "Terraform"
  CostCenter      = "IT-12345"
  BusinessUnit    = "Operations"
  DataClassification = "Restricted"
}

# Network configuration
address_space = ["10.0.0.0/16"]

# AKS configuration
kubernetes_version = "1.25.6"

# VM configuration
vm_admin_username = "adminuser"
vm_admin_ssh_public_key_path = "~/.ssh/id_rsa.pub"

# Database configuration
mysql_admin_username = "mysqladmin"
# mysql_admin_password is loaded from environment variable or Azure Key Vault
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

## License

This project is licensed under the MIT License - see the LICENSE file for details.