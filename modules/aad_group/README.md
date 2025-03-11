# Azure Active Directory Group Module

A Terraform module for managing Azure AD groups with comprehensive RBAC and membership management.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check AAD permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Directory')].roleDefinitionName" \
    -o tsv

# User Administrator role is required for group management
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "User Administrator" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. API Permissions
Ensure your Azure AD application has the following permissions:
- Group.ReadWrite.All
- User.Read.All
- Directory.ReadWrite.All

## Features
- Security group management
- Dynamic membership rules
- Group ownership control
- Role assignments
- Member management
- Access reviews
- Naming policies
- Expiration policies
- Group classification
- Activity logging

## Usage

```hcl
module "aad_group" {
  source = "./modules/aad_group"

  # Basic Configuration
  display_name     = "sg-prod-platform-admins"
  description      = "Platform administrators for production environment"
  security_enabled = true
  
  # Group Type and Classification
  group_types = ["Unified"]
  mail_enabled = true
  mail_nickname = "prod-platform-admins"
  
  # Owners Configuration
  owners = [
    data.azuread_user.admin.object_id,
    data.azuread_service_principal.devops.object_id
  ]
  
  # Members Configuration
  members = [
    data.azuread_user.platform_admin1.object_id,
    data.azuread_user.platform_admin2.object_id
  ]
  
  # Dynamic Membership (optional)
  dynamic_membership = {
    enabled = true
    rule = "user.department -eq \"Platform Engineering\" -and user.jobTitle -contains \"Administrator\""
  }
  
  # Expiration and Access Review
  expiration = {
    policy_enabled = true
    lifetime_in_days = 365
    renewal_enabled = true
  }
  
  # Role Assignments
  role_assignments = [
    {
      scope                = module.resource_group.id
      role_definition_name = "Contributor"
      description         = "Platform team access"
    },
    {
      scope                = module.aks.cluster_id
      role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
      description         = "AKS administration"
    }
  ]

  labels = {
    environment = "Production"
    managed_by  = "Terraform"
  }
}

# Example: Create groups for different environments
locals {
  environments = ["dev", "stage", "prod"]
  roles = ["admins", "developers", "readers"]
}

module "environment_groups" {
  for_each = { for pair in setproduct(local.environments, local.roles) : "${pair[0]}-${pair[1]}" => pair }
  source   = "./modules/aad_group"

  display_name     = "sg-${each.value[0]}-platform-${each.value[1]}"
  description      = "${title(each.value[1])} group for ${each.value[0]} environment"
  security_enabled = true
  
  # Configure based on role
  role_assignments = each.value[1] == "admins" ? [
    {
      scope                = module.resource_group[each.value[0]].id
      role_definition_name = "Contributor"
      description         = "Full platform access"
    }
  ] : each.value[1] == "developers" ? [
    {
      scope                = module.resource_group[each.value[0]].id
      role_definition_name = "Reader"
      description         = "Read platform access"
    }
  ] : []

  labels = {
    environment = each.value[0]
    role        = each.value[1]
    managed_by  = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |
| azuread | ~> 2.0 |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| display_name | Group display name | string | yes | - |
| description | Group description | string | no | null |
| security_enabled | Enable security | bool | no | true |
| group_types | Group types | list(string) | no | [] |
| mail_enabled | Enable mail | bool | no | false |
| mail_nickname | Mail nickname | string | no | null |
| owners | List of owner IDs | list(string) | no | [] |
| members | List of member IDs | list(string) | no | [] |
| dynamic_membership | Dynamic membership rules | object | no | null |
| expiration | Expiration settings | object | no | null |
| role_assignments | Role assignments | list(object) | no | [] |
| labels | Group labels | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| group_id | The group object ID |
| group_name | The group display name |
| group_members | List of group members |
| group_owners | List of group owners |

## Best Practices

### Group Management
- Use consistent naming
- Document purpose
- Regular membership review
- Monitor changes
- Audit access
- Review expiration
- Update documentation
- Track assignments

### Access Control
- Least privilege
- Role separation
- Regular review
- Monitor activity
- Document access
- Review policies
- Update permissions
- Track changes

### Security
- Enable security features
- Audit memberships
- Monitor activities
- Review permissions
- Track changes
- Document policies
- Regular updates
- Access reviews

### Compliance
- Documentation
- Regular reviews
- Audit logging
- Policy compliance
- Access tracking
- Change control
- Risk assessment
- Regular reporting

### Operations
- Automated management
- Regular cleanup
- Monitor usage
- Track changes
- Update procedures
- Document processes
- Review policies
- Maintain standards

### Common Group Types

#### Platform Teams
```hcl
display_name = "sg-prod-platform-admins"
role_assignments = [
  {
    role_definition_name = "Contributor"
    scope                = "/subscriptions/sub-id"
  }
]
```

#### AKS Administrators
```hcl
display_name = "sg-prod-aks-admins"
role_assignments = [
  {
    role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
    scope                = module.aks.cluster_id
  }
]
```

#### Key Vault Access
```hcl
display_name = "sg-prod-keyvault-users"
role_assignments = [
  {
    role_definition_name = "Key Vault Secrets User"
    scope                = module.keyvault.id
  }
]
```