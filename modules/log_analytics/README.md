# Azure Log Analytics Module

This module deploys a Log Analytics workspace with integrated monitoring solutions for Azure services.

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
az feature register --namespace Microsoft.OperationsManagement --name LogAnalytics

# Check registration status
az feature list -o table --query "[?contains(name, 'Microsoft.OperationsManagement/LogAnalytics')].{Name:name,State:properties.state}"

# After registration is complete, refresh the provider
az provider register --namespace Microsoft.OperationsManagement
```

### 3. AKS Integration Setup
```bash
# Get AKS Cluster ID
AKS_ID=$(az aks show -g "your-rg" -n "your-cluster" --query id -o tsv)

# Enable monitoring add-on with workspace
az aks enable-addons \
    --addons monitoring \
    --name "your-cluster" \
    --resource-group "your-rg" \
    --workspace-resource-id "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"
```

## Features

### Data Collection
- Custom logs
- Performance counters
- Azure service logs
- Container insights
- VM insights
- Network monitoring

### Analysis
- KQL query support
- Saved searches
- Custom dashboards
- Workbooks
- Alert rules

### Integration
- Azure Monitor
- Azure Security Center
- Azure Sentinel
- Application Insights
- Container Insights

## Usage

```hcl
module "log_analytics" {
  source = "./modules/log_analytics"

  name                = "prod-logs"
  resource_group_name = module.resource_group.name
  location           = "eastus2"
  retention_in_days  = 90
  
  solutions = [
    {
      solution_name = "ContainerInsights"
      publisher     = "Microsoft"
      product       = "OMSGallery/ContainerInsights"
    },
    {
      solution_name = "VMInsights"
      publisher     = "Microsoft"
      product       = "OMSGallery/VMInsights"
    }
  ]

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- Resource Group
- Service Principal for data collection
- Network access (if using private link)

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Workspace name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| retention_in_days | Data retention period | number | no | 30 |
| solutions | Monitoring solutions | list(map) | no | [] |
| sku | Workspace SKU | string | no | "PerGB2018" |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| workspace_id | The workspace ID |
| workspace_key | Primary shared key |
| workspace_customer_id | Customer ID for agent configuration |

## Best Practices
1. Right-size retention periods
2. Monitor data ingestion
3. Optimize queries
4. Use table partitioning
5. Configure data export
6. Regular cost review
7. Set up alerts
8. Document data sources

## Related Modules
- `aks` - For container monitoring
- `keyvault` - For secure credential storage
- `virtual_network` - For private link setup
- `storage` - For log archival

## Notes
- Plan data retention carefully
- Monitor ingestion costs
- Regular query optimization
- Consider compliance requirements
- Plan capacity for growth
- Regular backup of custom content