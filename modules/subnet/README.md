# Subnet Module

This module provisions an Azure subnet within an existing virtual network with configurable settings for service endpoints and delegations.

## Features

- Service endpoint support
- Subnet delegation capabilities
- Private endpoint network policies
- Service endpoint network policies
- NAT gateway association (optional)
- Route table association (optional)

## Usage

```hcl
module "subnet" {
  source = "./modules/subnet"

  subnet_name         = "aks-subnet"
  resource_group_name = "my-rg"
  vnet_name          = "my-vnet"
  address_prefixes    = ["10.0.1.0/24"]
  
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault"
  ]
  
  private_endpoint_network_policies_enabled     = true
  private_link_service_network_policies_enabled = true
}
```

## Required Providers

- azurerm ~> 3.0

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| subnet_name | Name of the subnet | string | yes |
| resource_group_name | Resource group name | string | yes |
| vnet_name | Virtual network name | string | yes |
| address_prefixes | Address prefixes for the subnet | list(string) | yes |
| service_endpoints | Service endpoints to enable | list(string) | no |
| delegations | Subnet delegations | list(object) | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet_id | The Subnet ID |
| subnet_name | The name of the Subnet |
| address_prefixes | The address prefixes of the Subnet |