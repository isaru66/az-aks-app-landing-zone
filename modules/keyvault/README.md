# Azure Key Vault Module

## Prerequisites and Setup

### 1. Required Permissions Setup

```bash
# Verify your user has the required roles
az role assignment list --assignee-principal-type User --query "[].{role:roleDefinitionName}" -o table

# If needed, assign Key Vault Administrator role
az role assignment create \
    --role "Key Vault Administrator" \
    --assignee-object-id $(az ad signed-in-user show --query id -o tsv) \
    --scope "/subscriptions/$(az account show --query id -o tsv)"

# For Azure AD integration, ensure you have Directory Readers role
# This usually requires a Global Administrator to grant
```

### 2. Setting up Private Endpoint Access

```bash
# Get Subnet ID for Private Endpoint (if using private endpoints)
az network vnet subnet show \
    --resource-group "your-vnet-rg" \
    --vnet-name "your-vnet-name" \
    --name "pe-subnet" \
    --query id -o tsv

# Get Private DNS Zone ID (if exists)
az network private-dns zone show \
    --resource-group "your-dns-rg" \
    --name "privatelink.vaultcore.azure.net" \
    --query id -o tsv
```

### 3. Configure Network Access

```bash
# Get your current IP address for firewall rules
curl -s https://api.ipify.org

# Get Virtual Network Resource ID
az network vnet show \
    --resource-group "your-vnet-rg" \
    --name "your-vnet-name" \
    --query id -o tsv
```

### 4. Setting up Managed Identities Access

```bash
# List User-Assigned Managed Identities
az identity list --query "[].{Name:name, Id:id, PrincipalId:principalId}" -o table

# Get System-Assigned Identity Object ID (if using AKS)
az aks show -g "your-rg" -n "your-aks-cluster" --query "identityProfile.kubeletidentity.objectId" -o tsv
```

## Features
- Secure key vault deployment with private endpoint support
- RBAC or Access Policy based authorization
- Network ACLs for IP and Virtual Network based access control
- Managed Identity integration
- Soft-delete and purge protection
- Diagnostic settings configuration

## Usage
```hcl
module "keyvault" {
  source = "./modules/keyvault"
  
  name                = "your-keyvault-name"
  resource_group_name = "your-resource-group"
  location            = "eastus"
  
  sku_name = "standard"
  
  network_acls = {
    bypass                     = "AzureServices"
    default_action            = "Deny"
    ip_rules                  = ["your-ip-address"]
    virtual_network_subnet_ids = ["subnet-id-for-access"]
  }
  
  private_endpoint_subnet_id = "subnet-id-for-private-endpoint"
  private_dns_zone_id       = "private-dns-zone-id"
}
```

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Key Vault name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| sku_name | SKU name (standard or premium) | string | no | "standard" |
| enabled_for_deployment | Enable VM deployment access | bool | no | false |
| network_acls | Network ACL configuration | map | no | null |
| private_endpoint_subnet_id | Subnet ID for private endpoint | string | no | null |
| tags | Resource tags | map | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| id | Key Vault resource ID |
| name | Key Vault name |
| uri | Key Vault URI |
| private_endpoint_ip | Private Endpoint IP (if enabled) |

## Security Best Practices
- Enable RBAC authorization instead of Access Policies when possible
- Use Private Endpoints for secure access
- Implement least-privilege access through fine-grained RBAC roles
- Enable soft-delete and purge protection
- Use network ACLs to restrict access to specific networks
- Monitor access through diagnostic settings