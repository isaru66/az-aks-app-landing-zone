data "azurerm_client_config" "current" {}

# Create user-assigned managed identity for AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Assign the Private DNS Zone Contributor role to the user-assigned identity
resource "azurerm_role_assignment" "dns_contributor" {
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Grant AKS identity AcrPull access to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.attach_acr ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

# resource "azurerm_monitor_workspace" "prometheus" {
#   count               = var.enable_managed_prometheus ? 1 : 0
#   name                = "${var.cluster_name}-prometheus"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   tags                = var.tags
# }

# resource "azurerm_dashboard_grafana" "grafana" {
#   count                   = var.enable_managed_prometheus ? 1 : 0
#   name                    = var.grafana_name
#   resource_group_name     = var.resource_group_name
#   location               = var.location
#   sku                    = "Standard"
#   api_key_enabled        = true
#   deterministic_outbound_ip_enabled = true
#   public_network_access_enabled     = true

#   identity {
#     type = "SystemAssigned"
#   }

#   azure_monitor_workspace_integrations {
#     resource_id = azurerm_monitor_workspace.prometheus[0].id
#   }

#   tags = var.tags
# }

# resource "azurerm_role_assignment" "grafana_admin" {
#   for_each             = var.enable_managed_prometheus ? toset(var.grafana_admin_object_ids) : []
#   scope                = azurerm_dashboard_grafana.grafana[0].id
#   role_definition_name = "Grafana Admin"
#   principal_id         = each.value
# }

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id    = var.private_dns_zone_id
  
  role_based_access_control_enabled = true
  
  default_node_pool {
    name                = var.system_node_pool_name
    vm_size             = var.system_node_pool_vm_size
    auto_scaling_enabled  = true
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

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    network_plugin_mode = null  # Removing overlay mode
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    # Removing pod_cidr as it's not compatible with basic Azure CNI
    load_balancer_sku  = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  microsoft_defender {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  oidc_issuer_enabled = var.enable_oidc_issuer
  workload_identity_enabled = var.enable_workload_identity

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
  
  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }

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

  monitor_metrics {
    annotations_allowed = "*"
    labels_allowed     = "*"
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic_setting" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

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
