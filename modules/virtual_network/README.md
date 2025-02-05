# Azure Virtual Network Module

This module deploys an Azure Virtual Network with comprehensive networking features for enterprise workloads.

## Features

### Network Design
- Custom address space
- Multiple subnet support
- Service endpoints
- DDoS protection
- Network watcher
- Flow logs
- Network security groups

### Security Features
- Service endpoint policies
- Private link support
- Custom DNS settings
- Network isolation
- Peering capabilities
- Route tables

### Monitoring
- Diagnostic settings
- Traffic analytics
- Network insights
- Health monitoring
- Metrics collection

## Usage

```hcl
module "vnet" {
  source = "./modules/virtual_network"

  name                = "prod-vnet"
  resource_group_name = module.resource_group.name
  location           = "eastus2"
  address_space      = ["10.0.0.0/16"]

  subnets = [
    {
      name           = "aks-subnet"
      address_prefix = "10.0.1.0/24"
      service_endpoints = [
        "Microsoft.KeyVault",
        "Microsoft.ContainerRegistry"
      ]
    },
    {
      name           = "pe-subnet"
      address_prefix = "10.0.2.0/24"
      private_endpoint_network_policies_enabled = true
    }
  ]

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- Resource Group
- Network Watcher (auto-created)
- Log Analytics workspace for diagnostics

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | VNet name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| address_space | VNet address spaces | list(string) | yes | - |
| subnets | Subnet configurations | list(map) | yes | [] |
| dns_servers | Custom DNS servers | list(string) | no | [] |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The Virtual Network ID |
| vnet_name | The name of the VNet |
| subnet_ids | Map of subnet names to IDs |
| address_space | The address space of the VNet |

## Best Practices
1. Plan IP addressing carefully
2. Implement proper network segmentation
3. Enable service endpoints where needed
4. Configure DNS appropriately
5. Monitor network flows
6. Regular security assessments
7. Document subnet allocations
8. Plan for future growth

## Related Modules
- `subnet` - For detailed subnet configuration
- `network_security_group` - For security rules
- `route_table` - For custom routing
- `bastion` - For secure access

## Notes
- Plan address space carefully
- Consider future peering requirements
- Document all service endpoints
- Monitor subnet utilization
- Regular network security reviews
- Consider compliance requirements