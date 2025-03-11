# Virtual Network Module

A Terraform module for deploying Azure Virtual Networks with comprehensive networking features and security controls.

## Prerequisites and Setup

### 1. Required Role Assignments and Permissions
```bash
# Check current networking permissions
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

### 2. DDoS Protection Setup (Optional)
```bash
# Check DDoS protection plan availability
az network ddos-protection list \
    --query "[].{Name:name, ResourceGroup:resourceGroup, VirtualNetworks:virtualNetworks}" \
    -o table

# Create DDoS protection plan if needed
az network ddos-protection create \
    --name "ddos-plan" \
    --resource-group "your-rg" \
    --location "eastus" \
    --vnets "your-vnet-name"
```

### 3. Network Watcher Requirements
```bash
# Ensure Network Watcher is enabled
az network watcher configure \
    --resource-group NetworkWatcherRG \
    --locations "eastus" \
    --enabled true
```

## Features

- Flexible address space configuration
- DNS settings management
- DDoS Protection Plan integration
- BGP community support
- Flow logging capabilities
- Network peering support
- Custom DNS servers
- Resource tagging
- Network security
- Subnet management
- Service endpoints
- Private endpoints

## Usage

```hcl
module "vnet" {
  source = "./modules/virtual_network"

  vnet_name           = "prod-vnet"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  address_space      = ["10.0.0.0/16"]
  
  dns_servers = ["168.63.129.16", "10.0.0.4"]  # Azure DNS and custom DNS
  
  # Optional DDoS protection
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }
  
  # Optional subnet configuration
  subnets = {
    aks = {
      name             = "snet-aks"
      address_prefixes = ["10.0.0.0/22"]
      service_endpoints = [
        "Microsoft.KeyVault",
        "Microsoft.ContainerRegistry"
      ]
    }
    pe = {
      name             = "snet-pe"
      address_prefixes = ["10.0.4.0/24"]
      enforce_private_link_endpoint_network_policies = true
    }
  }
  
  # Optional peering configuration
  peerings = [
    {
      name                         = "peer-to-hub"
      remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
      allow_virtual_network_access = true
      allow_forwarded_traffic     = true
      allow_gateway_transit       = false
      use_remote_gateways        = true
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
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
| vnet_name | Name of the virtual network | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| address_space | Address spaces for the VNet | list(string) | yes | - |
| dns_servers | Custom DNS servers | list(string) | no | [] |
| ddos_protection_plan | DDoS protection plan configuration | object | no | null |
| subnets | Subnet configurations | map(object) | no | {} |
| peerings | VNet peering configurations | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

### DDoS Protection Plan Object
```hcl
object({
  id     = string
  enable = bool
})
```

### Subnet Object
```hcl
object({
  name                                          = string
  address_prefixes                             = list(string)
  service_endpoints                            = optional(list(string))
  enforce_private_link_endpoint_network_policies = optional(bool)
  enforce_private_link_service_network_policies  = optional(bool)
  delegation                                   = optional(map(object))
})
```

### Peering Object
```hcl
object({
  name                         = string
  remote_virtual_network_id    = string
  allow_virtual_network_access = bool
  allow_forwarded_traffic     = bool
  allow_gateway_transit       = bool
  use_remote_gateways        = bool
})
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Virtual Network ID |
| name | The name of the Virtual Network |
| address_space | The address space of the Virtual Network |
| guid | The GUID of the Virtual Network |
| subnet_ids | Map of subnet names to IDs |

## Best Practices

### Address Space Planning
- Use RFC 1918 private address spaces
- Plan for future growth
- Consider peering requirements
- Document IP allocation strategy
- Reserve ranges for specific services
- Account for subnet requirements
- Plan for network expansion
- Consider hybrid connectivity

### Network Security
- Implement DDoS protection
- Configure proper DNS servers
- Use network segmentation
- Plan subnet structures
- Enable service endpoints
- Configure NSG rules
- Enable flow logs
- Regular security audits

### Peering Configuration
- Document peering relationships
- Consider asymmetric peering rules
- Plan for transitive peering needs
- Monitor peering status
- Consider bandwidth requirements
- Plan for failover scenarios
- Review routing implications
- Regular connectivity testing

### Resource Organization
- Use consistent naming
- Implement proper tagging
- Document network topology
- Regular configuration review
- Monitor resource usage
- Plan maintenance windows
- Set up monitoring
- Regular backup verification

### Cost Optimization
- Monitor bandwidth usage
- Review DDoS protection needs
- Optimize peering costs
- Plan capacity efficiently
- Regular usage review
- Consider reserved capacity
- Monitor data transfer
- Track associated resources