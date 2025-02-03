# Resource Group Module

A Terraform module for managing Azure Resource Groups with proper lifecycle management and access controls.

## Features

- Resource group provisioning
- Management lock capabilities
- Comprehensive tagging support
- Role-based access control (RBAC) integration
- Resource organization best practices
- Policy assignment support

## Usage

```hcl
module "resource_group" {
  source = "./modules/resource_group"

  name     = "prod-aks-rg"
  location = "eastus"
  
  enable_delete_lock = true
  
  tags = {
    Environment = "Production"
    Owner       = "Platform Team"
    CostCenter  = "IT-123"
    ManagedBy   = "Terraform"
  }
}

# With RBAC Assignment
module "resource_group_with_rbac" {
  source = "./modules/resource_group"

  name     = "prod-shared-rg"
  location = "eastus"
  
  role_assignments = [
    {
      principal_id         = "00000000-0000-0000-0000-000000000000"
      role_definition_name = "Contributor"
      description         = "Platform team access"
    }
  ]

  tags = {
    Environment = "Production"
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

### Naming Convention
Follow Azure naming conventions:
- Use lowercase letters and numbers
- Maximum 90 characters
- Valid characters: alphanumeric, underscore, and hyphen
- Must be unique within subscription

### Resource Organization
- Group related resources together
- Separate production and non-production resources
- Consider compliance requirements
- Plan for resource lifecycle management

### Security
- Implement least-privilege access
- Use management locks for critical resources
- Regular access reviews
- Document purpose and ownership

### Tags
Essential tags to consider:
- Environment
- Owner
- CostCenter
- Project
- Application
- ManagedBy