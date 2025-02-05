# Azure Kubernetes Service (AKS) Module

This module deploys a production-ready Azure Kubernetes Service cluster with security and operational best practices.

## Prerequisites and Setup

### 1. Required Azure CLI Extensions
```bash
# Install/update AKS preview extension
az extension add --name aks-preview
az extension update --name aks-preview

# Install Azure AD extension
az extension add --name azure-cli-ml
```

### 2. Required Role Assignments
Ensure you have the following roles:
- "Azure Kubernetes Service Cluster Admin Role"
- "Network Contributor" (for VNet integration)
- "User Access Administrator" (for assigning roles)

### 3. Gathering Required Credentials

#### Azure AD Group Setup for AKS Admin Access
```bash
# Create an Azure AD Admin Group if not exists
az ad group create --display-name "AKS-Cluster-Admins" --mail-nickname "aks-cluster-admins"

# Add users to the admin group
az ad group member add --group "AKS-Cluster-Admins" --member-id "user-object-id"

# Get admin_group_object_ids (required for terraform.tfvars)
az ad group show --group "AKS-Cluster-Admins" --query id -o tsv
```

#### User-Assigned Managed Identity (Optional)
```bash
# Create User-Assigned Managed Identity
az identity create --name "aks-identity" --resource-group "your-rg-name" --location "your-location"

# Get the identity ID and client ID
az identity show --name "aks-identity" --resource-group "your-rg-name"
```

#### Workload Identity Setup
```bash
# Enable OIDC issuer feature
az feature register --namespace "Microsoft.ContainerService" --name "AKS-AADWorkloadIdentity"

# Check registration status
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AADWorkloadIdentity')].{Name:name,State:properties.state}"

# When ready, refresh the registration
az provider register --namespace Microsoft.ContainerService
```

## Features

### Security Features
- Private cluster deployment
- Azure AD RBAC integration
- Network policies enabled
- Microsoft Defender for Containers
- Workload Identity support
- OIDC issuer enabled
- Azure CNI networking
- Host encryption enabled

### High Availability
- Multi-zone deployment
- Multiple node pools
- Auto-scaling enabled
- Regular automatic upgrades
- Backup for cluster state

### Monitoring and Operations
- Azure Monitor integration
- Container insights
- Diagnostic settings
- Prometheus metrics collection
- Azure Policy integration

## Usage

```hcl
module "aks" {
  source = "./modules/aks"

  cluster_name           = "prod-aks"
  resource_group_name    = module.resource_group.name
  location              = "eastus2"
  kubernetes_version    = "1.26.0"
  vnet_subnet_id        = module.subnet.id
  admin_group_object_ids = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]

  default_node_pool = {
    name                = "system"
    node_count         = 3
    vm_size            = "Standard_D4s_v3"
    availability_zones = [1, 2, 3]
    max_pods           = 30
  }

  user_node_pool = {
    name                = "user"
    node_count         = 3
    vm_size            = "Standard_D8s_v3"
    availability_zones = [1, 2, 3]
    max_pods           = 30
  }

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- Virtual Network with dedicated subnet
- Azure AD admin group
- Log Analytics workspace
- ACR (optional, for container registry)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| cluster_name | Name of the AKS cluster | string | yes | - |
| resource_group_name | Name of the resource group | string | yes | - |
| location | Azure region for deployment | string | yes | - |
| kubernetes_version | Kubernetes version | string | yes | - |
| vnet_subnet_id | Subnet ID for AKS | string | yes | - |
| admin_group_object_ids | Azure AD admin group IDs | list(string) | yes | - |
| default_node_pool | System node pool configuration | map | no | See defaults |
| user_node_pool | User node pool configuration | map | no | See defaults |
| acr_id | ACR ID for pull access | string | no | null |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The AKS cluster ID |
| kubelet_identity | The Kubelet identity |
| cluster_fqdn | FQDN of cluster control plane |
| node_resource_group | Auto-generated node resource group name |

## Best Practices
1. Always use private clusters in production
2. Enable multi-zone deployment for HA
3. Separate system and user workloads
4. Regular cluster upgrades
5. Monitor cluster metrics
6. Use Azure Policy for governance
7. Implement proper backup strategy
8. Configure network policies

## Related Modules
- `virtual_network` - For network configuration
- `log_analytics` - For monitoring
- `acr` - For container registry
- `private_dns_zone` - For private cluster DNS

## Notes
- Ensure subnet has enough IP addresses for pods
- Plan maintenance windows for upgrades
- Review security and compliance requirements
- Monitor node resource usage
- Regular security patches