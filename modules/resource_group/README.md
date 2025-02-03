# Resource Group Module

This module provisions an Azure Resource Group with proper tagging and management lock capabilities.

## Features

- Resource group creation
- Optional management lock
- Metadata tagging support
- Location specification

## Usage

```hcl
module "resource_group" {
  source = "./modules/resource_group"

  name     = "my-production-rg"
  location = "eastus"
  
  enable_delete_lock = true
  
  tags = {
    Environment = "Production"
    Owner       = "Platform Team"
    CostCenter  = "IT-123"
  }
}
```

## Required Providers

- azurerm ~> 3.0

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name | Name of the resource group | string | yes |
| location | Azure region | string | yes |
| enable_delete_lock | Enable deletion lock | bool | no |
| tags | Resource tags | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource Group ID |
| name | The name of the Resource Group |
| location | The location of the Resource Group |