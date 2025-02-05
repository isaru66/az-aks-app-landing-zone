# Log Analytics Module

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
- Centralized logging solution
- Custom log collection
- Query and analytics capabilities
- Alert rule management
- Data retention policies
- Workspace access control
- Solution integration

## Usage
```hcl
module "log_analytics" {
  source = "./modules/log_analytics"
  
  workspace_name      = "prod-logs"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  sku               = "PerGB2018"
  retention_in_days  = 30
  
  solutions = [
    {
      solution_name = "ContainerInsights"
      publisher     = "Microsoft"
      product       = "OMSGallery/ContainerInsights"
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| workspace_name | Name of Log Analytics workspace | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| sku | Pricing tier (Free, PerGB2018, Premium) | string | no | "PerGB2018" |
| retention_in_days | Data retention in days | number | no | 30 |
| solutions | List of solutions to install | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| workspace_id | The Log Analytics Workspace ID |
| workspace_key | The primary shared key |
| workspace_customer_id | The Workspace (Customer) ID |

## Best Practices
- Set appropriate retention periods
- Configure proper access controls
- Enable necessary solutions only
- Monitor workspace usage
- Set up alert rules
- Use proper tagging
- Enable diagnostic settings