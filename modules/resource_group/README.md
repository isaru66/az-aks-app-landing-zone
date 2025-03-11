# Resource Group Module

A Terraform module for managing Azure Resource Groups with comprehensive access control and organization features.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check Resource Group management permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Resource Group')].roleDefinitionName" \
    -o tsv

# Assign Resource Group Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Resource Group Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Resource Lock Setup (Optional but Recommended)
```bash
# List existing locks
az lock list \
    --resource-group "your-rg" \
    --output table

# Create delete lock (prevents accidental deletion)
az lock create \
    --name "prevent-delete" \
    --resource-group "your-rg" \
    --lock-type CanNotDelete
```

### 3. Policy Assignment
```bash
# List available policies
az policy definition list \
    --query "[?contains(displayName, 'Resource Group')].{Name:displayName, Description:description}" \
    --output table

# Assign required tags policy
az policy assignment create \
    --name 'require-resource-group-tags' \
    --display-name 'Require tags on resource groups' \
    --policy 'required-tag-keys'
```

## Features
- Resource group lifecycle management
- Resource organization and grouping
- Access control management
- Policy enforcement
- Resource locking capabilities
- Tag management
- Budget tracking
- Role assignment management
- Diagnostic settings
- Activity logging

## Usage

```hcl
module "resource_group" {
  source = "./modules/resource_group"
  
  name     = "prod-aks-rg"
  location = "eastus"
  
  # Optional resource locking
  lock_level = "CanNotDelete"  # Optional: ReadOnly, CanNotDelete
  
  # Required tags
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "AKS Infrastructure"
    Owner       = "Platform Team"
    CostCenter  = "IT-12345"
  }
}

# With RBAC Assignment
module "resource_group_with_rbac" {
  source = "./modules/resource_group"

  name     = "prod-shared-rg"
  location = "eastus"
  
  # Role assignments for access control
  role_assignments = [
    {
      principal_id         = "00000000-0000-0000-0000-000000000000"
      role_definition_name = "Contributor"
      description         = "Platform team access"
    },
    {
      principal_id         = "11111111-1111-1111-1111-111111111111"
      role_definition_name = "Reader"
      description         = "Monitoring team access"
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
| name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| lock_level | Resource lock level | string | no | null |
| enable_delete_lock | Enable deletion lock | bool | no | false |
| role_assignments | List of role assignments | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

### Role Assignment Object Structure

```hcl
object({
  principal_id         = string
  role_definition_name = string
  description         = string
})
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource Group ID |
| name | The name of the Resource Group |
| location | The location of the Resource Group |

## Best Practices
- Use consistent naming conventions
- Implement proper tagging strategy
- Consider resource locks for production
- Group related resources together
- Implement RBAC at resource group level
- Apply relevant policies
- Monitor resource usage
- Regular access review
- Cost tracking
- Activity logging

## Naming Convention
Follow Azure's recommended pattern:
```
rg-<environment>-<region>-<workload>
```
Examples:
- rg-prod-eastus-aks
- rg-dev-westus-shared
- rg-stage-eastus2-data

## Policy Recommendations
Consider implementing these policies:
- Require specific tags
- Enforce naming convention
- Restrict resource types
- Enforce resource locks
- Require network security
- Enable diagnostic settings

## Cost Management
- Set up budgets
- Track spending by tags
- Monitor resource usage
- Set up cost alerts
- Regular cost review
- Resource optimization

## Security Controls
- Regular access review
- Principle of least privilege
- Activity log monitoring
- Resource locking
- Policy enforcement
- Audit logging

## Monitoring
Enable monitoring for:
- Resource changes
- Access patterns
- Policy compliance
- Cost trends
- Activity logs
- Resource health