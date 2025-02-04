# Azure Bastion Module

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
# Check if you have the required role for public IP creation
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Network Contributor')].roleDefinitionName" \
    -o tsv

# Assign Network Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Network Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

## Features
- Secure remote access to VMs without public IP exposure
- Native Azure Portal integration
- Support for both SSH and RDP protocols
- Advanced security with Azure AD integration
- Network logging and monitoring capabilities

## Usage
```hcl
module "bastion" {
  source = "./modules/bastion"
  
  name                = "prod-bastion"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  
  subnet_id          = module.subnet["AzureBastionSubnet"].id
  public_ip_name     = "bastion-pip"
  
  scale_units        = 2  # For improved availability
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Bastion host name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| subnet_id | AzureBastionSubnet ID | string | yes | - |
| public_ip_name | Public IP name | string | yes | - |
| scale_units | Number of scale units | number | no | 2 |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| bastion_id | The Bastion resource ID |
| bastion_public_ip | The public IP of Bastion |
| bastion_dns_name | The DNS name of Bastion |

## Security Best Practices
- Always use AzureBastionSubnet for Bastion deployment
- Implement proper NSG rules for the Bastion subnet
- Enable Azure AD authentication when possible
- Monitor and audit Bastion usage
- Use tags for resource tracking
- Configure diagnostic settings for logging

## Subnet Requirements
- Subnet must be named "AzureBastionSubnet"
- Minimum subnet size: /27
- NSG requirements:
  - Inbound: Allow ports 443 from Internet
  - Outbound: Allow ports 3389/22 to VNet
  - Outbound: Allow port 443 to Internet

## Accessing VMs
```bash
# Verify VM access requirements
az vm list \
    --resource-group "your-vm-rg" \
    --query "[].{Name:name, PrivateIP:privateIps}" \
    -o table

# Ensure NSG allows Bastion subnet access
az network nsg rule list \
    --resource-group "your-nsg-rg" \
    --nsg-name "your-vm-nsg" \
    --query "[].{Name:name, Access:access, SourceAddressPrefix:sourceAddressPrefix, DestinationPortRange:destinationPortRange}" \
    -o table
```