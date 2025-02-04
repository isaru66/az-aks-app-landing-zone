# Common Configuration
location            = "southeastasia"
resource_group_name = "my-secure-storage-rg"

# Tags
tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
  Project     = "AKS Infrastructure"
  Owner       = "Platform Team"
}

# Network Configuration
virtual_network_name          = "jm-example-vnet"
address_space                 = ["10.0.0.0/16"]
network_security_group_name   = "jm-example-nsg"
subnet_name                   = "default-subnet"
subnet_prefix                 = "10.0.1.0/24"
subnets = {
  aks = {
    name           = "aks-subnet"
    address_prefix = "10.0.4.0/22"
  }
  pe-subnet = {
    name           = "pe-subnet"
    address_prefix = "10.0.8.0/24"
  }
}

# AKS Configuration
aks_cluster_name          = "example-aks"
kubernetes_version        = "1.28.3"
network_plugin           = "azure"
network_policy           = "azure"
dns_service_ip          = "172.16.0.10"
service_cidr            = "172.16.0.0/16"
private_cluster_enabled = true
sku_tier                = "Standard"
automatic_channel_upgrade = "stable"
private_dns_zone_id      = "/subscriptions/SUBSCRIPTION_ID/resourceGroups/DNS_RG/providers/Microsoft.Network/privateDnsZones/privatelink.LOCATION.azmk8s.io"

# Security Configuration
admin_group_object_ids    = ["85151f3e-784d-4ed4-82ac-f4895d2fcf5e"]
enable_defender          = true
enable_workload_identity = true
enable_oidc_issuer       = true
identity_type            = "UserAssigned"
azure_policy_enabled     = true

# Node Pools Configuration
system_node_pool_name                = "system"
system_node_pool_vm_size            = "Standard_D2ds_v4"
system_node_pool_enable_auto_scaling = true
system_node_pool_min_count          = 2
system_node_pool_max_count          = 4
system_node_pool_os_disk_size_gb    = 128
system_node_pool_zones              = ["1", "3"]

work_node_pool_name                 = "jmworkload"
work_node_pool_vm_size             = "Standard_D2ds_v4"
work_node_pool_enable_auto_scaling  = true
work_node_pool_min_count           = 2
work_node_pool_max_count           = 6
work_node_pool_os_disk_size_gb     = 256
work_node_pool_zones               = ["1", "3"]

# Monitoring Configuration
log_analytics_workspace_name = "aks-monitoring-workspace"
log_analytics_workspace_sku = "PerGB2018"
log_analytics_retention_days = 30

# Maintenance Configuration
maintenance_window = {
  allowed = [
    {
      day   = "Sunday"
      hours = [1, 2, 3, 4]
    }
  ]
  not_allowed = [
    {
      start = "2023-12-24T00:00:00Z"
      end   = "2023-12-26T00:00:00Z"
    }
  ]
}

# Key Vault Configuration
keyvault_name = "jm-kv-001"
keyvault_sku  = "standard"
keyvault_network_acls = {
  bypass                     = "AzureServices"
  default_action            = "Deny"
  ip_rules                  = []
  virtual_network_subnet_ids = []
}

# Storage Configuration
storage_identity_type = "SystemAssigned"
storage_user_assigned_identity_ids = []

# ACR Configuration
acr_name                   = "jmexampleacr001"
acr_sku                    = "Premium"
acr_public_access_enabled = false