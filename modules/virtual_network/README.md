# Virtual Network Module

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

# For DDoS Protection, verify DDoS Protection Contributor role
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "DDoS Protection Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Setting up DDoS Protection (Optional)
```bash
# Create DDoS Protection Plan
az network ddos-protection create \
    --name "your-ddos-plan" \
    --resource-group "your-rg" \
    --location "your-location" \
    --query id -o tsv
```

### 3. Network Watcher Requirements
```bash
# Enable Network Watcher in your region
az network watcher configure \
    --resource-group NetworkWatcherRG \
    --locations "your-location" \
    --enabled true

# Verify Network Watcher status
az network watcher list \
    --query "[].{Location:location, Enabled:provisioningState}" \
    -o table
```

### 4. DNS Configuration
```bash
# List available private DNS zones
az network private-dns zone list \
    --query "[].{Name:name, ResourceGroup:resourceGroup}" \
    -o table

# Get custom DNS server IPs (if using Azure AD DS or custom DNS)
az network dns record-set list \
    --resource-group "your-dns-rg" \
    --zone-name "your-dns-zone" \
    --query "[].{Name:name, Type:type, TTL:ttl, Records:aRecords[].ipv4Address}" \
    -o table
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

## Usage

```hcl
module "vnet" {
  source = "./modules/virtual_network"

  vnet_name           = "prod-vnet"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  address_space      = ["10.0.0.0/16"]
  
  dns_servers = ["168.63.129.16", "10.0.0.4"]  # Azure DNS and custom DNS
  
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# With peering configuration
module "vnet_with_peering" {
  source = "./modules/virtual_network"

  vnet_name           = "prod-vnet-2"
  resource_group_name = module.resource_group.name
  location           = "eastus2"
  address_space      = ["172.16.0.0/16"]

  peerings = [
    {
      name                         = "peer-to-prod"
      remote_virtual_network_id    = module.vnet.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways         = false
    }
  ]
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
| peerings | VNet peering configurations | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

### DDoS Protection Plan Object

```hcl
object({
  id     = string
  enable = bool
})
```

### Peering Object

```hcl
object({
  name                         = string
  remote_virtual_network_id    = string
  allow_virtual_network_access = bool
  allow_forwarded_traffic      = bool
  allow_gateway_transit        = bool
  use_remote_gateways         = bool
})
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Virtual Network ID |
| name | The name of the Virtual Network |
| address_space | The address space of the Virtual Network |
| guid | The GUID of the Virtual Network |

## Best Practices

### Address Space Planning
- Use RFC 1918 private address spaces
- Plan for future growth
- Consider peering requirements
- Document IP allocation strategy

### Network Security
- Implement DDoS protection
- Configure proper DNS servers
- Use network segmentation
- Plan subnet structures

### Peering Configuration
- Document peering relationships
- Consider asymmetric peering rules
- Plan for transitive peering needs
- Monitor peering status

### Resource Organization
- Use consistent naming
- Implement proper tagging
- Document network topology
- Regular configuration review