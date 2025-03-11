# Azure Kubernetes Service (AKS) Module

A comprehensive Terraform module for deploying production-ready Azure Kubernetes Service clusters with best practices.

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

### 3. Required Resource Providers
```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights
```

## Features

- Private cluster deployment with Azure CNI networking
- Multi-availability zone system and user node pools
- Autoscaling configuration with optimization profiles
- Azure AD RBAC integration
- Microsoft Defender for Containers integration
- Azure Monitor integration with Log Analytics
- Workload Identity and OIDC support
- Maintenance window configuration
- Azure Linux (CBL-Mariner) node OS
- Managed Prometheus and Grafana integration
- Private DNS zone integration
- Azure Container Registry integration
- Network policy (Calico) support

## Usage

```hcl
module "aks" {
  source = "./modules/aks"

  # Core Configuration
  cluster_name         = "prod-aks-cluster"
  location            = "eastus"
  resource_group_name = module.resource_group.name
  kubernetes_version  = "1.26"

  # Node Pool Configuration
  system_node_pool = {
    name         = "system"
    vm_size      = "Standard_D4s_v3"
    min_count    = 1
    max_count    = 3
    zones        = [1, 2, 3]
    node_labels  = { "role" = "system" }
    node_taints  = ["CriticalAddonsOnly=true:NoSchedule"]
  }

  user_node_pool = {
    name         = "user"
    vm_size      = "Standard_D4s_v3"
    min_count    = 1
    max_count    = 5
    zones        = [1, 2, 3]
    node_labels  = { "role" = "user" }
  }

  # Networking
  vnet_subnet_id = module.subnet.id
  network_plugin = "azure"
  network_policy = "azure"
  
  # Identity and Security
  admin_group_object_ids = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
  
  # Monitoring
  log_analytics_workspace_id = module.log_analytics.id
  enable_managed_prometheus = true
  monitor_workspace_id      = module.monitor_workspace.id
  grafana_admin_object_ids = ["yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"]

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
| cluster_name | The name of the AKS cluster | string | yes | - |
| location | Azure region for the cluster | string | yes | - |
| resource_group_name | Name of the resource group | string | yes | - |
| kubernetes_version | Kubernetes version | string | yes | - |
| vnet_subnet_id | Subnet ID for CNI networking | string | yes | - |
| private_dns_zone_id | Private DNS Zone ID for private cluster | string | no | null |
| admin_group_object_ids | AAD group IDs for admin access | list(string) | yes | - |
| system_node_pool_name | Name of the system node pool | string | no | "system" |
| system_node_pool_vm_size | VM size for system nodes | string | no | "Standard_D4s_v3" |
| system_node_pool_min_count | Minimum node count | number | no | 1 |
| system_node_pool_max_count | Maximum node count | number | no | 3 |
| work_node_pool_name | Name of the user node pool | string | no | "user" |
| work_node_pool_vm_size | VM size for user nodes | string | no | "Standard_D4s_v3" |
| work_node_pool_min_count | Minimum node count | number | no | 1 |
| work_node_pool_max_count | Maximum node count | number | no | 5 |
| enable_managed_prometheus | Enable Azure Managed Prometheus | bool | no | false |
| monitor_workspace_id | Azure Monitor workspace ID | string | no | null |
| grafana_admin_object_ids | Grafana admin user object IDs | list(string) | no | [] |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The AKS cluster ID |
| cluster_name | The name of the AKS cluster |
| cluster_fqdn | The FQDN of the AKS cluster |
| kube_config | The kubeconfig for cluster access |
| kubelet_identity | The kubelet managed identity |
| aks_identity | The AKS cluster managed identity |

## Advanced Features

### Workload Identity
Workload Identity enables pod-managed identities without the need for credentials in code:
```hcl
workload_identity_enabled = true
oidc_issuer_enabled      = true
```

### Maintenance Window
Configure maintenance windows to control when updates are applied:
```hcl
maintenance_window = {
  allowed = [
    {
      day   = "Sunday"
      hours = [0, 1, 2]
    }
  ]
}
```

### Auto-scaler Profile
Customize cluster autoscaling behavior:
```hcl
auto_scaler_profile = {
  balance_similar_node_groups = true
  max_graceful_termination_sec = 600
  scale_down_delay_after_add = "10m"
}
```

## Notes

1. **Networking**: The module uses Azure CNI networking by default for better performance and security. Ensure your subnet has sufficient IP addresses.

2. **Security**: Private cluster deployment is recommended for production environments. Use network policies and proper RBAC configuration.

3. **Monitoring**: Enable managed Prometheus and Grafana for comprehensive cluster monitoring. Configure proper retention policies.

4. **Updates**: Use maintenance windows and node surge settings to control cluster updates. Regular updates are crucial for security.

5. **Scaling**: Configure appropriate autoscaling parameters based on your workload patterns. Monitor scaling events for optimization.