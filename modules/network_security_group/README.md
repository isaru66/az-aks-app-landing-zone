# Network Security Group (NSG) Module

A Terraform module for creating and managing Azure Network Security Groups with comprehensive security rules.

## Features

- Flexible security rule configuration
- Support for service tags
- Application security group integration
- Priority-based rule management
- Source/destination filtering
- Protocol and port management
- Statefull packet inspection
- Azure Policy integration ready

## Usage

```hcl
module "nsg" {
  source = "./modules/network_security_group"

  nsg_name            = "aks-subnet-nsg"
  resource_group_name = module.resource_group.name
  location           = "eastus"

  security_rules = [
    {
      name                         = "allow_aks_api"
      priority                     = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureCloud"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow AKS API Server access"
    },
    {
      name                         = "deny_all_inbound"
      priority                     = 4096
      direction                   = "Inbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all inbound traffic"
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
| nsg_name | Name of the NSG | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| security_rules | List of security rules | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

### Security Rule Object Structure

```hcl
object({
  name                         = string
  priority                     = number
  direction                   = string
  access                      = string
  protocol                    = string
  source_port_range          = string
  destination_port_range     = string
  source_address_prefix      = string
  destination_address_prefix = string
  description                = string
})
```

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | The NSG resource ID |
| nsg_name | The name of the NSG |
| security_rules | List of configured security rules |

## Best Practices

### Rule Priority
- Use priorities 100-499 for allow rules
- Use priorities 500-4096 for deny rules
- Leave gaps between rules for future insertions

### Service Tags
Utilize Azure service tags for better maintainability:
- AzureCloud
- VirtualNetwork
- Internet
- AzureLoadBalancer
- AzureTrafficManager

### Security Considerations
- Implement least-privilege access
- Use specific port ranges instead of wildcards
- Document rule purposes using descriptions
- Regular audit of security rules

## Common Configurations

### AKS Cluster Security Rules
```hcl
security_rules = [
  {
    name                         = "allow_aks_api"
    priority                     = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "VirtualNetwork"
  }
]
```