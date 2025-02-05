# Azure Container Registry (ACR) Module

This module deploys an Azure Container Registry with enterprise-grade security and replication features.

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

### 4. Configure Network Access
```bash
# Get your current IP for firewall rules
CURRENT_IP=$(curl -s https://api.ipify.org)

# Configure network rule (if needed)
az acr network-rule add \
    --name "your-acr-name" \
    --resource-group "your-rg" \
    --ip-address $CURRENT_IP
```

## Features

### Security Features
- Private endpoint access
- Admin account disabled
- Azure AD authentication
- Network rules configured
- Content trust enabled
- Vulnerability scanning
- Customer-managed keys support

### High Availability
- Geo-replication support
- Zone redundancy
- Premium SKU features
- Auto-scaling enabled
- Image retention policies

### Operations
- Webhook support
- Task automation
- Image pruning
- Quarantine policy
- OCI artifact support

## Usage

```hcl
module "acr" {
  source = "./modules/acr"

  name                = "prodacr"
  resource_group_name = module.resource_group.name
  location           = "eastus2"
  sku               = "Premium"
  subnet_id          = module.subnet.id
  private_dns_zone_id = module.dns.private_dns_zone_id

  georeplications = [
    {
      location = "westus2"
      zone_redundancy_enabled = true
    }
  ]

  retention_policy = {
    days    = 30
    enabled = true
  }

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- Virtual Network with subnet for private endpoint
- Private DNS zone for ACR
- Log Analytics workspace for diagnostics
- AKS cluster (optional, for integration)

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
| sku | SKU (Basic/Standard/Premium) | string | no | "Premium" |
| subnet_id | Subnet ID for private endpoint | string | yes | - |
| private_dns_zone_id | Private DNS zone ID | string | yes | - |
| georeplications | Replication configurations | list(map) | no | [] |
| retention_policy | Image retention policy | map | no | null |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| registry_id | The ACR resource ID |
| login_server | The ACR login server URL |
| admin_username | Admin username (if enabled) |
| private_endpoint_ip | Private endpoint IP address |

## Best Practices
1. Use Premium SKU for production
2. Enable geo-replication for HA
3. Configure retention policies
4. Regular vulnerability scanning
5. Implement image signing
6. Monitor storage usage
7. Use CI/CD integration
8. Regular access review

## Related Modules
- `aks` - For Kubernetes integration
- `private_dns_zone` - For DNS resolution
- `keyvault` - For storing credentials
- `log_analytics` - For monitoring

## Notes
- Registry names must be globally unique
- Premium SKU required for private endpoints
- Plan storage capacity
- Consider CI/CD integration
- Regular security assessments
- Monitor replication status