# Azure Container Registry (ACR) Module

A Terraform module for deploying Azure Container Registry with premium features and security best practices.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check your current roles
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table

# Assign ACR roles if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "AcrPull" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"

az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "AcrPush" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Setting up AKS Integration
```bash
# Get AKS Kubelet Identity Object ID
AKS_KUBELET_ID=$(az aks show -g "your-rg" -n "your-cluster" \
    --query "identityProfile.kubeletidentity.objectId" -o tsv)

# Assign AcrPull role to AKS kubelet identity
az role assignment create \
    --assignee $AKS_KUBELET_ID \
    --role "AcrPull" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/your-rg/providers/Microsoft.ContainerRegistry/registries/your-acr-name"
```

### 3. Private Endpoint Setup
```bash
# Get Subnet ID for Private Endpoint
SUBNET_ID=$(az network vnet subnet show \
    --resource-group "your-vnet-rg" \
    --vnet-name "your-vnet" \
    --name "pe-subnet" \
    --query id -o tsv)

# Get Private DNS Zone ID
DNS_ZONE_ID=$(az network private-dns zone show \
    --resource-group "your-dns-rg" \
    --name "privatelink.azurecr.io" \
    --query id -o tsv)
```

## Features

- Premium tier ACR with enhanced security features
- Private endpoint integration
- Managed identity support
- Network access restrictions
- RBAC integration
- Diagnostic settings support
- Geo-replication ready
- Container image scanning
- Image retention policies
- Webhook support

## Usage

```hcl
module "acr" {
  source = "./modules/acr"

  name                = "myacrpremium"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  sku               = "Premium"
  
  # Disable admin authentication in favor of Azure AD
  admin_enabled       = false
  
  # Optional geo-replication
  georeplication_locations = ["eastus2", "westus2"]
  
  # Network configuration
  public_network_access_enabled = false
  network_rule_set = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
    virtual_network = {
      subnet_ids = [module.subnet["acr"].id]
    }
  }
  
  # Private endpoint configuration
  private_endpoint = {
    subnet_id            = module.subnet["pe-subnet"].id
    private_dns_zone_ids = [module.private_dns_zone["acr"].id]
  }

  # Enable features
  retention_policy = {
    days    = 30
    enabled = true
  }

  trust_policy = {
    enabled = true
  }

  quarantine_policy_enabled = true
  
  # Identity configuration
  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Grant AKS access to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
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
| name | Registry name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| sku | SKU (Basic, Standard, Premium) | string | no | "Premium" |
| admin_enabled | Enable admin user | bool | no | false |
| public_network_access_enabled | Enable public access | bool | no | false |
| georeplication_locations | Geo-replication locations | list(string) | no | [] |
| network_rule_set | Network rules configuration | map | no | null |
| private_endpoint | Private endpoint configuration | map | no | null |
| retention_policy | Retention policy settings | map | no | null |
| trust_policy | Trust policy settings | map | no | null |
| quarantine_policy_enabled | Enable quarantine policy | bool | no | false |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| id | The ACR resource ID |
| name | The name of the ACR |
| login_server | The ACR login server URL |
| principal_id | The principal ID of system-assigned identity |
| private_endpoint_ip | Private endpoint IP address |

## Best Practices

### Security
- Use Premium SKU for enhanced security features
- Disable public network access when possible
- Use private endpoints for secure access
- Enable managed identity
- Implement proper RBAC
- Regular image scanning
- Enable quarantine policy for untrusted images

### Networking
- Configure network rules carefully
- Use service endpoints where needed
- Plan private endpoint DNS integration
- Consider geo-replication for global deployments

### Operations
- Implement proper tagging
- Configure retention policies
- Monitor quota usage
- Regular security audits
- Implement CI/CD integration
- Set up webhooks for important events

### Cost Management
- Choose appropriate SKU
- Monitor storage usage
- Clean up unused images
- Use automated cleanup policies
- Consider geo-replication costs