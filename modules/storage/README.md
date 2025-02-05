# Azure Storage Account Module

This module creates an Azure Storage Account configured for secure blob storage in a production environment.

## Security Features

- Zone-redundant storage (ZRS) for high availability
- Private endpoint access only (no public access)
- Infrastructure encryption enabled
- Azure AD authentication only (shared access keys disabled)
- Strict network rules with default deny
- Blob versioning enabled
- 30-day retention policy for deleted blobs
- Diagnostic logging enabled

## Required Resources

- A subnet for the private endpoint
- A private DNS zone for blob storage
- A Log Analytics workspace for diagnostics
- A service principal or managed identity for blob access

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| storage_account_name | Name of the storage account | string | yes |
| resource_group_name | Name of the resource group | string | yes |
| location | Azure region for deployment | string | yes |
| subnet_id | Subnet ID for private endpoint | string | yes |
| private_dns_zone_id | Private DNS zone ID | string | yes |
| principal_id | Principal ID for blob data access | string | yes |
| log_analytics_workspace_id | Log Analytics workspace ID | string | yes |
| tags | Resource tags | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the storage account |
| storage_account_name | The name of the storage account |
| private_endpoint_ip | Private endpoint IP address |
| principal_id | Storage account's managed identity principal ID |