# Private DNS Zone Module

A Terraform module for managing Azure Private DNS Zones with virtual network links and record sets.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check Private DNS permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'DNS')].roleDefinitionName" \
    -o tsv

# Assign Private DNS Zone Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Private DNS Zone Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Common Private DNS Zone Names
- AKS: privatelink.{region}.azmk8s.io
- ACR: privatelink.azurecr.io
- Key Vault: privatelink.vaultcore.azure.net
- Storage: privatelink.blob.core.windows.net
- MySQL: privatelink.mysql.database.azure.com
- Event Hub: privatelink.servicebus.windows.net
- App Service: privatelink.azurewebsites.net

## Features
- Private DNS zone management
- Virtual network link configuration
- Record set management (A, AAAA, CNAME, etc.)
- Auto-registration support
- Cross-subscription linking
- Tags and metadata
- Access control (RBAC)
- Zone redundancy
- Record TTL management
- Record set validation

## Usage

```hcl
module "private_dns_zone" {
  source = "./modules/private_dns_zone"

  # Basic Configuration
  name                = "privatelink.azurecr.io"
  resource_group_name = module.resource_group.name
  tags                = var.tags

  # Virtual Network Links
  virtual_network_links = [
    {
      name                  = "hub-vnet-link"
      virtual_network_id    = module.hub_vnet.id
      registration_enabled  = false
      tags                 = var.tags
    },
    {
      name                  = "spoke-vnet-link"
      virtual_network_id    = module.spoke_vnet.id
      registration_enabled  = true
      tags                 = var.tags
    }
  ]

  # Optional Record Sets
  a_records = {
    "myacr" = {
      ttl     = 300
      records = ["10.0.1.4"]
    }
  }

  cname_records = {
    "myapp" = {
      ttl    = 300
      record = "myapp.region.azurecontainer.io"
    }
  }
}

# Example: AKS Private Cluster DNS Zone
module "aks_dns_zone" {
  source = "./modules/private_dns_zone"

  name                = "privatelink.eastus.azmk8s.io"
  resource_group_name = module.resource_group.name
  
  virtual_network_links = [
    {
      name                  = "aks-vnet-link"
      virtual_network_id    = module.vnet.id
      registration_enabled  = false
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
| name | DNS zone name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| virtual_network_links | Virtual network link configurations | list(object) | no | [] |
| soa_record | SOA record configuration | object | no | null |
| a_records | A record configurations | map(object) | no | {} |
| aaaa_records | AAAA record configurations | map(object) | no | {} |
| cname_records | CNAME record configurations | map(object) | no | {} |
| mx_records | MX record configurations | map(object) | no | {} |
| ptr_records | PTR record configurations | map(object) | no | {} |
| srv_records | SRV record configurations | map(object) | no | {} |
| txt_records | TXT record configurations | map(object) | no | {} |
| tags | Resource tags | map(string) | no | {} |

### Virtual Network Link Object
```hcl
object({
  name                  = string
  virtual_network_id    = string
  registration_enabled  = bool
  tags                 = map(string)
})
```

### Record Objects

```hcl
# A Record
object({
  ttl     = number
  records = list(string)
})

# CNAME Record
object({
  ttl    = number
  record = string
})
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Private DNS Zone ID |
| name | The name of the Private DNS Zone |
| number_of_record_sets | The number of record sets |
| virtual_network_links | The virtual network links |

## Best Practices

### Naming Convention
- Use meaningful domain names
- Consider organizational structure
- Plan for future expansion
- Document naming scheme
- Follow Azure private endpoint patterns
- Use consistent subdomain structure
- Consider regional requirements
- Maintain naming standards

### Virtual Network Links
- Enable auto-registration where appropriate
- Monitor link status
- Plan for cross-region links
- Consider hub-spoke architectures
- Review link costs
- Monitor registration status
- Plan for scaling
- Consider hybrid scenarios

### Record Management
- Use appropriate TTL values
- Document record purposes
- Regular record auditing
- Plan for DR scenarios
- Monitor record usage
- Implement change control
- Validate DNS resolution
- Regular cleanup

### Security
- Restrict zone access
- Monitor DNS queries
- Regular security reviews
- Document access controls
- Implement RBAC
- Audit zone changes
- Review network access
- Monitor suspicious activity

### Cost Management
- Plan virtual network links
- Monitor query volume
- Optimize record count
- Regular usage review
- Consider zone consolidation
- Track linked resources
- Review auto-registration
- Monitor API usage

### Common Zone Types
```hcl
# Key Vault
name = "privatelink.vaultcore.azure.net"

# Container Registry
name = "privatelink.azurecr.io"

# Storage Account
name = "privatelink.blob.core.windows.net"

# AKS
name = "privatelink.{region}.azmk8s.io"

# Database
name = "privatelink.mysql.database.azure.com"
```