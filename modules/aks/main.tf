# Get current Azure client and subscription configuration
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Create user-assigned managed identity for AKS
# This identity will be used by the AKS cluster to manage Azure resources
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Assign the Private DNS Zone Contributor role to the user-assigned identity
# This allows AKS to manage DNS records in the private DNS zone
resource "azurerm_role_assignment" "dns_contributor" {
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Grant AKS identity Network Contributor role on the subnet
# This allows AKS to manage network resources in the specified subnet
resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Grant AKS identity Managed Identity Operator role on itself
# This allows AKS to manage its own identity
resource "azurerm_role_assignment" "mi_operator" {
  scope                = azurerm_user_assigned_identity.aks_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Grant AKS identity AcrPull access to ACR
# This allows AKS to pull images from the Azure Container Registry
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.attach_acr ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

# Grant AKS identity Contributor role on the resource group
# This allows AKS to manage resources within its resource group
resource "azurerm_role_assignment" "rg_contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Grant AKS identity Reader role on the subscription
# This allows AKS to read subscription-level resources and metadata
resource "azurerm_role_assignment" "subscription_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Create Azure Monitor workspace for Prometheus metrics collection
# This is used when managed Prometheus is enabled
resource "azurerm_monitor_workspace" "prometheus" {
  count               = var.enable_managed_prometheus && var.monitor_workspace_id == null ? 1 : 0
  name                = "${var.cluster_name}-prometheus"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Add monitoring data access role assignment for Grafana
# This allows Grafana to read metrics from the Prometheus workspace
resource "azurerm_role_assignment" "monitoring_data_reader" {
  count                = var.enable_managed_prometheus ? 1 : 0
  scope                = var.monitor_workspace_id != null ? var.monitor_workspace_id : azurerm_monitor_workspace.prometheus[0].id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.grafana[0].identity[0].principal_id
}

# Create managed Grafana instance for visualizing metrics
# This provides a managed visualization platform for monitoring
resource "azurerm_dashboard_grafana" "grafana" {
  count                             = var.enable_managed_prometheus ? 1 : 0
  name                              = var.grafana_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  sku                              = "Standard"
  grafana_major_version            = "10"
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = var.monitor_workspace_id != null ? var.monitor_workspace_id : azurerm_monitor_workspace.prometheus[0].id
  }

  tags = var.tags
}

# Assign Grafana admin role to specified users
# This allows designated users to manage the Grafana instance
resource "azurerm_role_assignment" "grafana_admin" {
  for_each             = var.enable_managed_prometheus ? toset(var.grafana_admin_object_ids) : []
  scope                = azurerm_dashboard_grafana.grafana[0].id
  role_definition_name = "Grafana Admin"
  principal_id         = each.value
}

# Grant Grafana monitoring reader access at subscription level
# This allows Grafana to read monitoring data across the subscription
resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  count                = var.enable_managed_prometheus ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.grafana[0].identity[0].principal_id
}

# Grant Grafana admin access to current user
# This ensures the deploying user has admin access to Grafana
resource "azurerm_role_assignment" "grafana_admin_current" {
  count                = var.enable_managed_prometheus ? 1 : 0
  scope                = azurerm_dashboard_grafana.grafana[0].id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Create the AKS cluster with specified configuration
# This is the main AKS cluster resource with all its components
resource "azurerm_kubernetes_cluster" "this" {
  # Basic cluster configuration
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.sku_tier
  automatic_upgrade_channel = var.automatic_channel_upgrade
  
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id    = var.private_dns_zone_id
  
  role_based_access_control_enabled = true
  
  # AAD RBAC configuration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled    = true
    tenant_id             = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
  }
  
  # System node pool configuration
  # These nodes run critical system pods
  default_node_pool {
    name                = var.system_node_pool_name
    vm_size             = var.system_node_pool_vm_size
    auto_scaling_enabled = true
    node_count          = null  # Must be null when enable_auto_scaling is true
    max_count           = var.system_node_pool_max_count
    min_count           = var.system_node_pool_min_count
    os_disk_size_gb     = var.system_node_pool_os_disk_size_gb
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = var.subnet_id
    zones               = var.system_node_pool_zones
    
    only_critical_addons_enabled = true
    os_sku                      = "AzureLinux"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "production"
    }
    max_pods             = 30
    orchestrator_version = var.kubernetes_version
    
    upgrade_settings {
      max_surge                     = var.max_surge
      drain_timeout_in_minutes      = var.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.node_soak_duration_in_minutes
    }
  }

  # Cluster identity configuration
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # Kubelet identity configuration
  kubelet_identity {
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
    client_id                = azurerm_user_assigned_identity.aks_identity.client_id
    object_id                = azurerm_user_assigned_identity.aks_identity.principal_id
  }

  # Network configuration
  # Defines networking model and related settings
  network_profile {
    network_plugin           = var.network_plugin
    network_policy          = var.network_policy
    network_plugin_mode     = var.network_plugin == "azure" ? "overlay" : null
    service_cidr           = var.service_cidr
    dns_service_ip         = var.dns_service_ip
    load_balancer_sku     = "standard"
    outbound_type         = "loadBalancer"
  }

  # Log Analytics integration
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # Microsoft Defender for Containers configuration
  microsoft_defender {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  oidc_issuer_enabled = var.enable_oidc_issuer
  workload_identity_enabled = var.enable_workload_identity

  # Maintenance window configuration
  # Defines when automated maintenance can occur
  maintenance_window {
    dynamic "allowed" {
      for_each = var.maintenance_window != null ? var.maintenance_window.allowed : []
      content {
        day   = allowed.value.day
        hours = allowed.value.hours
      }
    }
    dynamic "not_allowed" {
      for_each = var.maintenance_window != null ? var.maintenance_window.not_allowed : []
      content {
        end   = not_allowed.value.end
        start = not_allowed.value.start
      }
    }
  }

  azure_policy_enabled = var.azure_policy_enabled
  
  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  # Cluster autoscaler configuration
  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "random"  # Options: random, most-pods, least-waste, priority
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_percentage          = 45
    new_pod_scale_up_delay          = "10s"
    scale_down_delay_after_add      = "10m"
    scale_down_delay_after_delete   = "10s"
    scale_down_delay_after_failure  = "3m"
    scale_down_unneeded            = "10m"
    scale_down_unready             = "20m"
    scale_down_utilization_threshold = 0.5
    scan_interval                   = "10s"
    skip_nodes_with_local_storage   = true
    skip_nodes_with_system_pods     = true
  }

  # Prometheus metrics configuration
  monitor_metrics {
    annotations_allowed = "*"
    labels_allowed     = "*"
  }

  tags = var.tags
  
  depends_on = [ azurerm_user_assigned_identity.aks_identity, azurerm_role_assignment.mi_operator ]
}

# Configure AKS monitoring access
# Allows AKS to publish metrics to Azure Monitor
resource "azurerm_role_assignment" "aks_monitoring_access" {
  count                = var.enable_managed_prometheus ? 1 : 0
  scope                = var.monitor_workspace_id != null ? var.monitor_workspace_id : azurerm_monitor_workspace.prometheus[0].id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}


# Create worker node pool
# These nodes run application workloads
resource "azurerm_kubernetes_cluster_node_pool" "work" {
  name                  = var.work_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size              = var.work_node_pool_vm_size
  auto_scaling_enabled  = true
  node_count           = null  # Must be null when enable_auto_scaling is true
  max_count            = var.work_node_pool_max_count
  min_count            = var.work_node_pool_min_count
  os_disk_size_gb      = var.work_node_pool_os_disk_size_gb
  vnet_subnet_id       = var.subnet_id
  zones                = var.work_node_pool_zones
  
  os_sku = "AzureLinux"
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = "production"
  }
  max_pods             = 30
  orchestrator_version = var.kubernetes_version
  
  upgrade_settings {
    max_surge                     = var.max_surge
    drain_timeout_in_minutes      = var.drain_timeout_in_minutes
    node_soak_duration_in_minutes = var.node_soak_duration_in_minutes
  }
  
  tags = var.tags
}

# Create data collection rule for AKS metrics
# Configures how metrics are collected and routed
resource "azurerm_monitor_data_collection_rule" "aks" {
  count               = var.enable_managed_prometheus ? 1 : 0
  name                = "${var.cluster_name}-metrics"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    monitor_account {
      monitor_account_id = var.monitor_workspace_id != null ? var.monitor_workspace_id : azurerm_monitor_workspace.prometheus[0].id
      name              = "prometheus"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheus"]
  }

  description = "Data collection rule for AKS cluster metrics"
  tags        = var.tags
}

# Associate data collection rule with AKS cluster
# Links the collection rule to the cluster
resource "azurerm_monitor_data_collection_rule_association" "aks" {
  count                   = var.enable_managed_prometheus ? 1 : 0
  name                    = "${var.cluster_name}-metrics-dcra"
  target_resource_id      = azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.aks[0].id
}