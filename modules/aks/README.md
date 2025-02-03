# AKS Module

This module provisions an Azure Kubernetes Service (AKS) cluster with production-grade configurations.

## Features

- Azure Linux (CBL-Mariner) based node pools
- Azure AD RBAC integration
- Private cluster capability
- Advanced networking with Azure CNI
- Autoscaling for both system and user node pools
- Multi-zone deployment support
- Microsoft Defender and Log Analytics integration
- Workload Identity and OIDC support
- Maintenance window configuration

## Usage

```hcl
module "aks" {
  source = "./modules/aks"

  cluster_name          = "my-aks-cluster"
  location             = "eastus"
  resource_group_name  = "my-rg"
  kubernetes_version   = "1.26"
  
  # Node Pool Configuration
  system_node_pool_name = "system"
  system_node_pool_vm_size = "Standard_D4s_v3"
  system_node_pool_min_count = 1
  system_node_pool_max_count = 3
  
  work_node_pool_name = "user"
  work_node_pool_vm_size = "Standard_D4s_v3"
  work_node_pool_min_count = 1
  work_node_pool_max_count = 5
  
  # Networking
  network_plugin = "azure"
  network_policy = "azure"
  subnet_id      = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/.../subnets/..."
  
  # Identity and Security
  identity_type = "SystemAssigned"
  admin_group_object_ids = ["xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
  
  # Monitoring and Diagnostics
  log_analytics_workspace_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/..."
  diagnostic_setting_name    = "aks-diagnostics"
  
  tags = {
    Environment = "Production"
  }
}
```

## Required Providers

- azurerm ~> 3.0

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cluster_name | The name of the AKS cluster | string | yes |
| location | Azure region | string | yes |
| resource_group_name | Resource group name | string | yes |
| kubernetes_version | Kubernetes version | string | yes |
| system_node_pool_name | System node pool name | string | yes |
| work_node_pool_name | User node pool name | string | yes |
| subnet_id | Subnet ID for CNI networking | string | yes |
| admin_group_object_ids | AAD group IDs for admin access | list(string) | yes |
| log_analytics_workspace_id | Log Analytics Workspace ID for diagnostic settings | string | yes |
| diagnostic_setting_name | Name of the diagnostic setting | string | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The AKS cluster ID |
| kube_config | Kubeconfig for cluster access |
| cluster_identity | System-assigned identity details |