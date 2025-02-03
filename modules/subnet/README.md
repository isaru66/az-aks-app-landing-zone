# Subnet Module

A Terraform module for creating and managing Azure Virtual Network subnets with advanced networking features.

## Features

- Service endpoint configuration
- Subnet delegation support
- Network security group association
- Route table association
- Private endpoint policies
- Service endpoint policies
- NAT gateway integration
- IP address space management

## Usage

```hcl
module "subnet" {
  source = "./modules/subnet"

  subnet_name           = "aks-subnet"
  resource_group_name   = module.resource_group.name
  vnet_name            = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
  
  delegations = [
    {
      name = "aks-delegation"
      service_delegation = {
        name    = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  ]

  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
  
  nsg_id = module.nsg.id
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
| subnet_name | Name of the subnet | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| vnet_name | Virtual network name | string | yes | - |
| address_prefixes | CIDR ranges for the subnet | list(string) | yes | - |
| service_endpoints | List of service endpoints | list(string) | no | [] |
| delegations | List of subnet delegations | list(object) | no | [] |
| nsg_id | NSG ID to associate | string | no | null |
| route_table_id | Route table ID to associate | string | no | null |
| private_endpoint_network_policies_enabled | Enable/disable private endpoint policies | bool | no | true |
| private_link_service_network_policies_enabled | Enable/disable private link policies | bool | no | true |

### Delegation Object Structure

```hcl
object({
  name = string
  service_delegation = object({
    name    = string
    actions = list(string)
  })
})
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Subnet ID |
| name | The name of the Subnet |
| address_prefixes | The address prefixes of the Subnet |
| resource_group_name | The name of the resource group |

## Best Practices

### IP Address Planning
- Plan address space carefully for future growth
- Consider IP requirements for services
- Leave space for additional endpoints
- Document IP allocation

### Service Endpoints
Common service endpoints to consider:
- Microsoft.Storage
- Microsoft.KeyVault
- Microsoft.ContainerRegistry
- Microsoft.Sql
- Microsoft.Web

### Security
- Associate NSG for traffic control
- Enable private endpoint policies
- Use service endpoints for Azure services
- Implement proper route tables

### Delegations
Common delegation scenarios:
- AKS clusters
- App Service
- Azure NetApp Files
- SQL Managed Instances
- Azure Container Instances