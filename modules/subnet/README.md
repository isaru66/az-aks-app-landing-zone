# Subnet Module

A Terraform module for managing Azure Virtual Network Subnets with service delegation and security features.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check network permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Network')].roleDefinitionName" \
    -o tsv

# Assign Network Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Network Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Pre-deployment Checks
```bash
# Check address space availability
az network vnet show \
    --resource-group "your-rg" \
    --name "your-vnet" \
    --query "addressSpace.addressPrefixes"

# List existing subnets
az network vnet subnet list \
    --resource-group "your-rg" \
    --vnet-name "your-vnet" \
    --query "[].{Name:name, Prefix:addressPrefix}" \
    -o table
```

## Features
- Service delegation support
- Private endpoint policies
- Service endpoints
- NAT gateway integration
- Route table association
- NSG association
- Subnet delegation
- Address prefix management
- Service endpoint policies
- Network policies

## Usage

```hcl
module "subnet" {
  source = "./modules/subnet"

  # Basic Configuration
  name                = "snet-aks-prod"
  resource_group_name = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes    = ["10.0.1.0/24"]
  
  # Service Endpoints
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry",
    "Microsoft.Storage"
  ]
  
  # Private Endpoint Policies
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
  
  # Service Delegation (for AKS)
  delegation = {
    name = "aks-delegation"
    service_delegation = {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
  
  # Network Security Group
  network_security_group_id = module.nsg["aks"].id
  
  # Route Table
  route_table_id = module.route_table["aks"].id
  
  # NAT Gateway (optional)
  nat_gateway_id = module.nat_gateway.id
}

# Example: Private Endpoint Subnet
module "subnet_pe" {
  source = "./modules/subnet"

  name                = "snet-pe-prod"
  resource_group_name = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes    = ["10.0.2.0/24"]
  
  private_endpoint_network_policies_enabled = true
  
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

# Example: MySQL Flexible Server Subnet
module "subnet_mysql" {
  source = "./modules/subnet"

  name                = "snet-mysql-prod"
  resource_group_name = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes    = ["10.0.3.0/24"]
  
  delegation = {
    name = "mysql-delegation"
    service_delegation = {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Example: Multiple Subnets with for_each
locals {
  subnets = {
    aks = {
      name             = "snet-aks-prod"
      address_prefix   = "10.0.1.0/24"
      delegation      = "Microsoft.ContainerService/managedClusters"
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    }
    pe = {
      name             = "snet-pe-prod"
      address_prefix   = "10.0.2.0/24"
      private_endpoint_enabled = true
      service_endpoints = ["Microsoft.KeyVault"]
    }
    mysql = {
      name             = "snet-mysql-prod"
      address_prefix   = "10.0.3.0/24"
      delegation      = "Microsoft.DBforMySQL/flexibleServers"
    }
  }
}

module "subnets" {
  source   = "./modules/subnet"
  for_each = local.subnets

  name                = each.value.name
  resource_group_name = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes    = [each.value.address_prefix]
  
  service_endpoints = lookup(each.value, "service_endpoints", [])
  
  delegation = lookup(each.value, "delegation", null) != null ? {
    name = "${each.key}-delegation"
    service_delegation = {
      name    = each.value.delegation
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  } : null
  
  private_endpoint_network_policies_enabled = lookup(each.value, "private_endpoint_enabled", false)
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Subnet name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| virtual_network_name | VNet name | string | yes | - |
| address_prefixes | Address prefixes | list(string) | yes | - |
| service_endpoints | Service endpoints | list(string) | no | [] |
| delegation | Service delegation | object | no | null |
| private_endpoint_network_policies_enabled | Enable PE policies | bool | no | false |
| private_link_service_network_policies_enabled | Enable PLS policies | bool | no | false |
| network_security_group_id | NSG ID | string | no | null |
| route_table_id | Route table ID | string | no | null |
| nat_gateway_id | NAT gateway ID | string | no | null |

## Outputs

| Name | Description |
|------|-------------|
| id | The subnet ID |
| name | The name of the subnet |
| address_prefix | The address prefix |
| resource_group_name | The resource group name |

## Best Practices

### Address Space Planning
- Use CIDR calculator
- Plan for growth
- Consider service requirements
- Document allocations
- Reserve ranges
- Plan expansions
- Monitor usage
- Regular review

### Security
- NSG associations
- Service endpoints
- Network policies
- Access controls
- Regular audits
- Monitor traffic
- Update policies
- Security baseline

### Service Integration
- Proper delegations
- Endpoint policies
- Service requirements
- Dependency mapping
- Version compatibility
- Integration testing
- Update procedures
- Documentation

### Networking
- Route tables
- NAT gateways
- Load balancers
- Private endpoints
- Traffic routing
- DNS integration
- Network monitoring
- Performance tracking

### Common Subnet Types

#### AKS Subnet
```hcl
name = "snet-aks-prod"
address_prefixes = ["10.0.1.0/24"]
delegation = {
  name = "aks"
  service_delegation = {
    name = "Microsoft.ContainerService/managedClusters"
  }
}
```

#### Private Endpoint Subnet
```hcl
name = "snet-pe-prod"
address_prefixes = ["10.0.2.0/24"]
private_endpoint_network_policies_enabled = true
```

#### Database Subnet
```hcl
name = "snet-mysql-prod"
address_prefixes = ["10.0.3.0/24"]
delegation = {
  name = "mysql"
  service_delegation = {
    name = "Microsoft.DBforMySQL/flexibleServers"
  }
}
```