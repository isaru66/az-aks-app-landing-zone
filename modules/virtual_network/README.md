# Virtual Network Module

This module provisions an Azure Virtual Network with configurable address spaces and DNS settings.

## Features

- Configurable address space
- Custom DNS servers support
- DDoS protection plan integration (optional)
- Tags support for resource management
- Designed for production workloads

## Usage

```hcl
module "vnet" {
  source = "./modules/virtual_network"

  vnet_name           = "my-vnet"
  resource_group_name = "my-rg"
  location           = "eastus"
  address_space      = ["10.0.0.0/16"]
  
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
| vnet_name | Name of the virtual network | string | yes |
| resource_group_name | Resource group name | string | yes |
| location | Azure region | string | yes |
| address_space | Address space for the VNet | list(string) | yes |
| dns_servers | Custom DNS servers | list(string) | no |
| tags | Resource tags | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The Virtual Network ID |
| vnet_name | The name of the Virtual Network |
| address_space | The address space of the Virtual Network |