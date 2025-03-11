# Azure Bastion Module

A Terraform module for deploying Azure Bastion service with secure remote access capabilities.

## Prerequisites and Setup

### 1. Required Network Configuration
```bash
# Verify the AzureBastionSubnet exists (required name)
az network vnet subnet show \
    --resource-group "your-vnet-rg" \
    --vnet-name "your-vnet" \
    --name "AzureBastionSubnet" \
    --query id -o tsv

# If needed, create the subnet (minimum /27 required)
az network vnet subnet create \
    --resource-group "your-vnet-rg" \
    --vnet-name "your-vnet" \
    --name "AzureBastionSubnet" \
    --address-prefix "10.0.1.0/27"
```

### 2. Required Public IP Setup
```bash
# Check public IP availability
az network public-ip list \
    --query "[?contains(name, 'bastion')].{Name:name, IPAddress:ipAddress, AllocationMethod:publicIpAllocationMethod}" \
    -o table
```

## Features
- Secure remote access to VMs without public IP exposure
- Native Azure Portal integration
- Support for both SSH and RDP protocols
- Advanced security with Azure AD integration
- Network logging and monitoring capabilities
- Host scaling capabilities
- Copy/paste support
- Session recording (optional)
- File transfer support
- Connection diagnostics
- Native client support

## Usage

```hcl
module "bastion" {
  source = "./modules/bastion"
  
  name                = "bas-prod-eastus"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  
  # Network Configuration
  vnet_name          = module.vnet.name
  subnet_prefix      = "10.0.1.0/27"  # Must be at least /27
  
  # Public IP Configuration
  public_ip_name     = "pip-bastion-prod"
  public_ip_sku      = "Standard"
  allocation_method  = "Static"
  
  # Bastion Configuration
  sku               = "Standard"  # Standard SKU enables additional features
  scale_units       = 2  # Number of scale units (2-50)
  
  # Optional Features (Standard SKU only)
  enable_copy_paste = true
  enable_file_copy  = true
  enable_tunneling  = true
  
  # Optional IP Configuration
  ip_connect_enabled = true
  
  # Shareable Link Configuration (Standard SKU only)
  shareable_link_enabled = true
  
  # Native Client Support
  native_client_support = true

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
| name | Bastion host name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| vnet_name | Virtual network name | string | yes | - |
| subnet_prefix | Subnet address prefix | string | yes | - |
| public_ip_name | Public IP name | string | yes | - |
| public_ip_sku | Public IP SKU | string | no | "Standard" |
| allocation_method | IP allocation method | string | no | "Static" |
| sku | Bastion SKU | string | no | "Standard" |
| scale_units | Number of scale units | number | no | 2 |
| enable_copy_paste | Enable copy/paste | bool | no | true |
| enable_file_copy | Enable file copy | bool | no | true |
| enable_tunneling | Enable tunneling | bool | no | true |
| ip_connect_enabled | Enable IP connect | bool | no | true |
| shareable_link_enabled | Enable shareable links | bool | no | true |
| native_client_support | Enable native client | bool | no | true |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| bastion_id | The Bastion resource ID |
| bastion_public_ip | The public IP of Bastion |
| bastion_dns_name | The DNS name of Bastion |

## Security Best Practices

### Network Security
- Use Standard SKU for enhanced features
- Configure proper NSG rules
- Enable diagnostic logging
- Monitor access patterns
- Regular security audits
- Review access logs
- Monitor failed connections
- Implement session monitoring

### Access Control
- Use Azure AD authentication
- Implement RBAC
- Regular access reviews
- Monitor privileged access
- Session time limits
- Connection restrictions
- Audit logging
- Access policies

### Operational Security
- Regular updates
- Monitor health status
- Performance tracking
- Capacity planning
- Backup configurations
- Disaster recovery
- Change management
- Incident response

## Subnet Requirements

The AzureBastionSubnet has specific requirements:
- Name must be "AzureBastionSubnet"
- Minimum size is /27
- No route tables
- No delegation
- No NSG association
- Public IP required

## Accessing VMs

### Linux VMs
```bash
# Access via Azure Portal
Navigate to VM > Connect > Bastion > Use Bastion

# Access via Native Client
az network bastion ssh \
    --name "bastion-name" \
    --resource-group "rg-name" \
    --target-resource-id "vm-resource-id" \
    --auth-type "AAD"
```

### Windows VMs
```bash
# Access via Azure Portal
Navigate to VM > Connect > Bastion > Use Bastion

# Access via Native Client
az network bastion rdp \
    --name "bastion-name" \
    --resource-group "rg-name" \
    --target-resource-id "vm-resource-id"
```

## Monitoring

Enable monitoring for:
- Connection metrics
- Session duration
- Failed attempts
- Resource utilization
- Network throughput
- Session recordings
- Error patterns
- Performance metrics

## Cost Management
- Choose appropriate SKU
- Monitor usage patterns
- Scale units planning
- Review bandwidth costs
- Resource optimization
- Budget tracking
- Usage reporting
- Cost allocation