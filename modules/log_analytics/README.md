# Log Analytics Module

A Terraform module for deploying Azure Log Analytics Workspace with comprehensive monitoring and analytics capabilities.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check Log Analytics permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Log Analytics')].roleDefinitionName" \
    -o tsv

# Assign Log Analytics Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Log Analytics Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"

# For solution management, assign Monitoring Contributor
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Monitoring Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Azure Monitor Integration Setup
```bash
# Enable Azure Monitor features
az feature register --namespace Microsoft.Monitor \
    --name EnableDataExport

# Wait for registration
az feature show --namespace Microsoft.Monitor \
    --name EnableDataExport
```

### 3. AKS Integration Setup
```bash
# Get AKS resource ID
AKS_ID=$(az aks show -g "your-rg" -n "your-cluster" --query id -o tsv)

# Enable monitoring add-on
az aks enable-addons -a monitoring \
    -g "your-rg" \
    -n "your-cluster" \
    --workspace-resource-id "/subscriptions/your-sub/resourceGroups/your-rg/providers/Microsoft.OperationalInsights/workspaces/your-workspace"
```

## Features
- Centralized logging solution
- Custom log collection
- Query and analytics capabilities
- Alert rule management
- Data retention policies
- Workspace access control
- Solution integration
- Cross-workspace queries
- Custom table creation
- Data export configuration

## Usage
```hcl
module "log_analytics" {
  source = "./modules/log_analytics"
  
  workspace_name      = "prod-logs"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  sku               = "PerGB2018"
  retention_in_days  = 30
  
  # Enable solutions
  solutions = [
    {
      solution_name = "ContainerInsights"
      publisher     = "Microsoft"
      product       = "OMSGallery/ContainerInsights"
    },
    {
      solution_name = "KeyVaultAnalytics"
      publisher     = "Microsoft"
      product       = "OMSGallery/KeyVaultAnalytics"
    },
    {
      solution_name = "Security"
      publisher     = "Microsoft"
      product       = "OMSGallery/Security"
    }
  ]
  
  # Optional data export configuration
  data_exports = [
    {
      name            = "audit-logs"
      destination_id  = module.storage.id
      table_names     = ["AuditLogs"]
      enabled        = true
    }
  ]
  
  # Optional linked storage account
  linked_storage_account = {
    resource_id = module.storage.id
    type        = "CustomLogs"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Grant AKS monitoring access
resource "azurerm_role_assignment" "aks_monitoring" {
  scope                = module.log_analytics.id
  role_definition_name = "Monitoring Metrics Publisher"
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
| workspace_name | Workspace name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| sku | SKU (Free, PerGB2018, PerGB2018) | string | no | "PerGB2018" |
| retention_in_days | Data retention period | number | no | 30 |
| solutions | List of solutions to enable | list(object) | no | [] |
| data_exports | Data export configurations | list(object) | no | [] |
| linked_storage_account | Linked storage account config | object | no | null |
| daily_quota_gb | Daily data ingestion quota | number | no | null |
| internet_ingestion_enabled | Enable internet ingestion | bool | no | true |
| internet_query_enabled | Enable internet queries | bool | no | true |
| reservation_capacity_in_gb_per_day | Capacity reservation | number | no | null |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| id | Workspace resource ID |
| name | Workspace name |
| primary_shared_key | Primary access key |
| secondary_shared_key | Secondary access key |
| workspace_id | Workspace unique identifier |

## Best Practices
- Set appropriate retention periods based on compliance requirements
- Configure proper access controls using RBAC
- Enable necessary solutions based on workload requirements
- Monitor workspace usage and set appropriate quotas
- Set up alert rules for critical metrics
- Use proper tagging for cost allocation
- Enable diagnostic settings for workspace monitoring
- Implement data export for long-term retention
- Configure cross-workspace queries for centralized analytics
- Regular review of data ingestion patterns

## Query Examples

### Container Insights
```kusto
ContainerLog
| where TimeGenerated > ago(1h)
| where ContainerID != ""
| summarize count() by ContainerID, Image, Command
```

### Key Vault Analytics
```kusto
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| summarize count() by CallerIPAddress, Identity
```

### Security Insights
```kusto
SecurityEvent
| where EventID == 4624  // Successful logon
| summarize count() by Account, IpAddress
```

## Cost Management
- Monitor daily ingestion rates
- Set appropriate retention periods
- Use data export for cold storage
- Configure daily quotas
- Review solution costs
- Optimize queries for performance
- Consider capacity reservations for predictable workloads