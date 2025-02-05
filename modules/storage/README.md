# Azure Storage Account Module

This module creates an Azure Storage Account configured for secure blob storage in a production environment.

## Features

### Security Features
- Zone-redundant storage (ZRS) for high availability
- Private endpoint access only (no public access)
- Infrastructure encryption enabled
- Azure AD authentication only (shared access keys disabled)
- Strict network rules with default deny
- Blob versioning enabled
- 30-day retention policy for deleted blobs
- Diagnostic logging enabled

### Monitoring and Compliance
- Azure Monitor diagnostic settings
- Metrics collection enabled
- Audit logs configured
- Blob service-specific monitoring

### Network Configuration
- Private endpoint integration
- Custom DNS configuration
- Network rules for subnet access
- Service endpoint support

## Usage

```hcl
module "storage" {
  source = "./modules/storage"

  storage_account_name        = "mystorageaccount"
  resource_group_name        = "my-rg"
  location                   = "eastus2"
  subnet_id                  = "/subscriptions/.../subnets/pe-subnet"
  private_dns_zone_id        = "/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"
  principal_id              = "object-id-for-rbac"
  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"
  
  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- A subnet for the private endpoint
- A private DNS zone for blob storage
- A Log Analytics workspace for diagnostics
- A service principal or managed identity for blob access

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| storage_account_name | Name of the storage account | string | yes | - |
| resource_group_name | Name of the resource group | string | yes | - |
| location | Azure region for deployment | string | yes | - |
| subnet_id | Subnet ID for private endpoint | string | yes | - |
| private_dns_zone_id | Private DNS zone ID | string | yes | - |
| principal_id | Principal ID for blob data access | string | yes | - |
| log_analytics_workspace_id | Log Analytics workspace ID | string | yes | - |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the storage account |
| storage_account_name | The name of the storage account |
| private_endpoint_ip | Private endpoint IP address |
| principal_id | Storage account's managed identity principal ID |

## Example with Private Endpoint

```hcl
module "storage" {
  source = "./modules/storage"

  storage_account_name        = "mystorageaccount"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  subnet_id                  = module.network.subnet_ids["pe-subnet"]
  private_dns_zone_id        = module.dns.private_dns_zone_id
  principal_id              = data.azurerm_client_config.current.object_id
  log_analytics_workspace_id = module.monitoring.workspace_id

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
    ManagedBy   = "Terraform"
  }
}
```

## Best Practices
1. Always use private endpoints in production
2. Enable soft delete and versioning for data protection
3. Configure appropriate retention policies
4. Implement proper RBAC using Azure AD identities
5. Monitor storage metrics and set up alerts
6. Use infrastructure encryption for sensitive data
7. Regular security and access reviews

## Related Modules
- `private_dns_zone` - For DNS resolution of private endpoints
- `subnet` - For network configuration
- `log_analytics` - For monitoring and diagnostics

## Notes
- The storage account name must be globally unique
- ZRS replication is recommended for production workloads
- Make sure the subnet has the Microsoft.Storage service endpoint enabled