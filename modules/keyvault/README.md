# Azure Key Vault Module

This module deploys an Azure Key Vault configured for secure secret management in a production environment.

## Features

### Security Features
- Private endpoint access
- Purge protection enabled
- Soft delete enabled
- RBAC authorization
- Network ACLs configured
- TLS 1.2 enforcement
- Disk encryption integration

### Access Control
- Azure AD integration
- Fine-grained access policies
- Managed identity support
- Automated secret rotation
- Certificate management

### Monitoring and Compliance
- Azure Monitor integration
- Diagnostic logging
- Audit trail
- Activity logs
- Access monitoring

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

## Usage

```hcl
module "keyvault" {
  source = "./modules/keyvault"

  name                = "prod-kv"
  resource_group_name = module.resource_group.name
  location           = "eastus2"
  sku_name           = "premium"
  subnet_id          = module.subnet.id
  private_dns_zone_id = module.dns.private_dns_zone_id

  access_policies = [
    {
      object_id = data.azurerm_client_config.current.object_id
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete"
      ]
      key_permissions = [
        "Get",
        "List",
        "Create",
        "Delete"
      ]
      certificate_permissions = [
        "Get",
        "List",
        "Create",
        "Delete"
      ]
    }
  ]

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- Virtual Network with subnet for private endpoint
- Private DNS zone for Key Vault
- Log Analytics workspace for diagnostics
- Service principals or managed identities for access

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Key Vault name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| sku_name | SKU name (standard/premium) | string | no | "standard" |
| subnet_id | Subnet ID for private endpoint | string | yes | - |
| private_dns_zone_id | Private DNS zone ID | string | yes | - |
| access_policies | List of access policies | list(map) | no | [] |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | The Key Vault ID |
| key_vault_uri | The Key Vault URI |
| private_endpoint_ip | Private endpoint IP address |

## Best Practices
1. Always use private endpoints
2. Enable purge protection for production
3. Regular access review
4. Monitor vault operations
5. Use managed identities where possible
6. Implement secret rotation
7. Regular backup of secrets
8. Document access policies

## Related Modules
- `private_dns_zone` - For DNS resolution
- `subnet` - For network configuration
- `log_analytics` - For monitoring
- `aks` - For Kubernetes integration

## Notes
- Key Vault names must be globally unique
- Premium SKU required for HSM-backed keys
- Plan secret rotation policies
- Consider compliance requirements
- Regular security reviews recommended