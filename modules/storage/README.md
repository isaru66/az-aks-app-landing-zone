# Azure Storage Account Module

This module creates an Azure Storage Account configured for secure blob storage in a production environment.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check Storage Account permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Storage')].roleDefinitionName" \
    -o tsv

# Assign Storage Account Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Storage Account Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Private DNS Zone Setup
```bash
# Create Private DNS Zone for Blob Storage
az network private-dns zone create \
    --resource-group "your-rg" \
    --name "privatelink.blob.core.windows.net"

# Link zone to VNet
az network private-dns link vnet create \
    --resource-group "your-rg" \
    --zone-name "privatelink.blob.core.windows.net" \
    --name "blob-dns-link" \
    --virtual-network "your-vnet" \
    --registration-enabled false
```

## Features
- Private endpoint integration
- Hierarchical namespace support
- Network access controls
- Encryption configuration
- Lifecycle management
- CORS rules configuration
- Diagnostic settings
- SAS token management
- Container management
- Role assignments
- Access tier settings
- Versioning support

## Usage

```hcl
module "storage" {
  source = "./modules/storage"
  
  name                = "stproddata"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  
  # Account Configuration
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind            = "StorageV2"
  access_tier            = "Hot"
  
  # Security Features
  min_tls_version          = "TLS1_2"
  enable_https_traffic_only = true
  allow_blob_public_access  = false
  
  # Identity Configuration
  identity_type = "SystemAssigned"
  
  # Network Configuration
  public_network_access_enabled = false
  network_rules = {
    default_action             = "Deny"
    bypass                    = ["AzureServices"]
    ip_rules                 = []
    virtual_network_subnet_ids = [module.subnet["app"].id]
  }
  
  # Private Endpoint
  private_endpoint = {
    name                = "pe-storage"
    subnet_id           = module.subnet["pe"].id
    private_dns_zone_id = module.private_dns_zone["blob"].id
    subresource_names   = ["blob"]
  }
  
  # Blob Service Configuration
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    delete_retention_days    = 7
    container_delete_retention_days = 7
  }
  
  # Container Configuration
  containers = {
    logs = {
      name                  = "logs"
      container_access_type = "private"
    },
    data = {
      name                  = "data"
      container_access_type = "private"
    }
  }
  
  # Lifecycle Management
  lifecycle_rules = [
    {
      name    = "moveToArchive"
      enabled = true
      filters = {
        prefix_match = ["logs/"]
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_archive_after_days = 90
          delete_after_days          = 365
        }
        snapshot = {
          delete_after_days = 30
        }
      }
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Grant AKS access for persistent volumes
resource "azurerm_role_assignment" "aks_storage" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.aks.kubelet_identity.object_id
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
| name | Storage account name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| account_tier | Account tier | string | no | "Standard" |
| account_replication_type | Replication type | string | no | "GRS" |
| account_kind | Account kind | string | no | "StorageV2" |
| access_tier | Access tier | string | no | "Hot" |
| min_tls_version | Minimum TLS version | string | no | "TLS1_2" |
| identity_type | Identity type | string | no | "SystemAssigned" |
| network_rules | Network rules | object | no | null |
| private_endpoint | Private endpoint config | object | no | null |
| blob_properties | Blob service properties | object | no | null |
| containers | Container configurations | map(object) | no | {} |
| lifecycle_rules | Lifecycle management rules | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| id | The Storage Account ID |
| name | The name of the Storage Account |
| primary_access_key | The primary access key |
| primary_connection_string | The primary connection string |
| principal_id | The principal ID of managed identity |

## Best Practices

### Security
- Use private endpoints
- Enable firewall rules
- Implement network rules
- Use managed identities
- Enable soft delete
- Configure TLS version
- Regular key rotation
- Monitor access logs

### Performance
- Choose correct tier
- Configure access tiers
- Enable CDN if needed
- Monitor metrics
- Optimize requests
- Consider geo-replication
- Cache configuration
- Request optimization

### Data Management
- Configure lifecycle
- Enable versioning
- Backup strategy
- Retention policies
- Monitor capacity
- Data classification
- Access patterns
- Regular cleanup

### Monitoring
- Enable diagnostics
- Configure alerts
- Track metrics
- Monitor costs
- Performance tracking
- Capacity planning
- Security monitoring
- Usage analysis

### Cost Optimization
- Access tier selection
- Lifecycle management
- Monitor usage
- Clean old data
- Right-size capacity
- Review replication
- Optimize requests
- Monitor bandwidth

### Compliance
- Data residency
- Encryption settings
- Audit logging
- Access reviews
- Legal holds
- Retention policies
- Privacy controls
- Regular audits