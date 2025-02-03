# Network Security Group Module

This module provisions an Azure Network Security Group with configurable security rules for network traffic control.

## Features

- Configurable inbound and outbound security rules
- Priority-based rule processing
- Source/destination IP filtering
- Service tag support
- Application security group integration
- Port range configuration

## Usage

```hcl
module "nsg" {
  source = "./modules/network_security_group"

  nsg_name            = "aks-nsg"
  resource_group_name = "my-rg"
  location           = "eastus"
  
  security_rules = [
    {
      name                       = "allow_https"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range         = "*"
      destination_port_range    = "443"
      source_address_prefix     = "*"
      destination_address_prefix = "*"
    }
  ]
  
  tags = {
    Environment = "Production"
  }
}
```

## Required Providers

- azurerm ~> 3.0

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| nsg_name | Name of the NSG | string | yes |
| resource_group_name | Resource group name | string | yes |
| location | Azure region | string | yes |
| security_rules | List of security rules | list(object) | no |
| tags | Resource tags | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | The NSG ID |
| nsg_name | The name of the NSG |
| security_rules | List of configured security rules |