# Azure Container Registry (ACR) Module

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

- Premium tier ACR with enhanced security features
- Private endpoint integration
- Managed identity support
- Network access restrictions
- RBAC integration
- Diagnostic settings support
- Geo-replication ready

## Usage

```hcl
module "acr" {
  source = "./modules/acr"

  name                = "myacrpremium"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  sku               = "Premium"
  
  public_network_access_enabled = false
  subnet_id                    = module.subnet["pe-subnet"].id
  private_dns_zone_ids         = [azurerm_private_dns_zone.acr.id]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Grant AKS access to ACR
module "aks" {
  source = "./modules/aks"
  # ... other AKS configuration ...
  
  attach_acr = true
  acr_id     = module.acr.acr_id
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
| subnet_id | Subnet ID for private endpoint | string | yes | - |
| private_dns_zone_ids | DNS zone IDs for private endpoint | list(string) | yes | - |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| acr_id | The ACR resource ID |
| acr_name | The name of the ACR |
| acr_login_server | The ACR login server URL |
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

### Networking
- Configure network rules carefully
- Use service endpoints where needed
- Plan private endpoint DNS integration
- Consider geo-replication for global deployments

### Operations
- Implement proper tagging
- Plan retention policies
- Monitor quota usage
- Regular security audits
- Implement CI/CD integration