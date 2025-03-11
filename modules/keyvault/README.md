# Azure Key Vault Module

A Terraform module for deploying Azure Key Vault with comprehensive security features and access controls.

## Prerequisites and Setup

### 1. Required Permissions Setup
```bash
# Check your current Key Vault permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Key Vault')].roleDefinitionName" \
    -o tsv

# Assign Key Vault Administrator role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Key Vault Administrator" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Setting up Private Endpoint Access
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
    --name "privatelink.vaultcore.azure.net" \
    --query id -o tsv)
```

### 3. Configure Network Access
```bash
# Get your current IP for firewall rules
CURRENT_IP=$(curl -s https://api.ipify.org)

# Configure network rule (if needed)
az keyvault network-rule add \
    --name "your-keyvault-name" \
    --resource-group "your-rg" \
    --ip-address $CURRENT_IP
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
- HSM key support (Premium tier)
- Backup and restore capabilities
- Certificate management
- Secret rotation support

## Usage
```hcl
module "keyvault" {
  source = "./modules/keyvault"
  
  name                = "your-keyvault-name"
  resource_group_name = "your-resource-group"
  location            = "eastus"
  
  sku_name = "premium"
  
  # Enable RBAC authorization
  enable_rbac_authorization = true
  
  # Enable features
  purge_protection_enabled    = true
  soft_delete_retention_days = 7
  
  # Network configuration
  public_network_access_enabled = false
  network_acls = {
    bypass                     = "AzureServices"
    default_action            = "Deny"
    ip_rules                  = ["your-ip-address"]
    virtual_network_subnet_ids = [module.subnet["app"].id]
  }
  
  # Private endpoint configuration
  private_endpoint = {
    subnet_id            = module.subnet["pe-subnet"].id
    private_dns_zone_ids = [module.private_dns_zone["keyvault"].id]
  }
  
  # Access policies (if not using RBAC)
  access_policies = [
    {
      object_id = data.azurerm_client_config.current.object_id
      tenant_id = data.azurerm_client_config.current.tenant_id
      
      key_permissions = [
        "Get", "List", "Create", "Delete", "Update"
      ]
      secret_permissions = [
        "Get", "List", "Set", "Delete"
      ]
      certificate_permissions = [
        "Get", "List", "Create", "Delete", "Update"
      ]
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
| name | Key Vault name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| sku_name | SKU name (standard or premium) | string | no | "standard" |
| tenant_id | Azure AD tenant ID | string | yes | - |
| enable_rbac_authorization | Enable RBAC authorization | bool | no | true |
| enabled_for_deployment | Enable VM deployment access | bool | no | false |
| enabled_for_disk_encryption | Enable disk encryption | bool | no | false |
| enabled_for_template_deployment | Enable template deployment | bool | no | false |
| purge_protection_enabled | Enable purge protection | bool | no | true |
| soft_delete_retention_days | Soft delete retention days | number | no | 7 |
| public_network_access_enabled | Enable public access | bool | no | false |
| network_acls | Network ACL configuration | map | no | null |
| private_endpoint | Private endpoint configuration | map | no | null |
| access_policies | List of access policies | list(map) | no | [] |
| tags | Resource tags | map(string) | no | {} |

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
- Regularly rotate secrets and certificates
- Use managed identities for application access
- Enable automatic certificate renewal
- Implement backup strategy

## Monitoring Recommendations
- Enable diagnostic settings
- Configure alerts for unauthorized access attempts
- Monitor certificate expiration
- Track secret and key usage
- Set up activity log alerts
- Monitor vault capacity
- Track private endpoint connectivity

## Notes

1. **Naming**: Key Vault names must be globally unique and between 3-24 characters
2. **Recovery**: Soft-delete is enabled by default and cannot be disabled
3. **Network Access**: Private endpoint is recommended for production workloads
4. **HSM**: Premium SKU is required for HSM-backed keys
5. **Scaling**: Consider request limits when planning Key Vault usage