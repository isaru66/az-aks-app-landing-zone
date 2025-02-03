resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "virtual_network" {
  source                = "./modules/virtual_network"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  vnet_name             = var.virtual_network_name
  address_space         = var.address_space
  tags                  = var.tags
}

module "network_security_group" {
  source                = "./modules/network_security_group"
  resource_group_name   = azurerm_resource_group.this.name
  name                  = var.network_security_group_name
  location              = azurerm_resource_group.this.location
  tags                  = var.tags
}

module "subnet" {
  source                    = "./modules/subnet"
  for_each                  = var.subnets
  
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = module.virtual_network.virtual_network_name
  subnet_name               = each.value.name
  address_prefix            = each.value.address_prefix
  network_security_group_id = module.network_security_group.network_security_group_id
  
  depends_on = [
    module.virtual_network,
    module.network_security_group
  ]
}

module "private_dns_zone" {
  source              = "./modules/private_dns_zone"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  virtual_network_id  = module.virtual_network.virtual_network_id
  tags                = var.tags
}

module "aks" {
  source = "./modules/aks"

  # Basic cluster configuration
  cluster_name         = var.aks_cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kubernetes_version  = var.kubernetes_version
  sku_tier           = var.sku_tier

  # Network configuration
  subnet_id           = module.subnet["aks"].subnet_id
  dns_service_ip      = var.dns_service_ip
  docker_bridge_cidr  = var.docker_bridge_cidr
  service_cidr        = var.service_cidr
  network_plugin     = var.network_plugin
  network_policy     = var.network_policy

  # Private cluster configuration
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id    = module.private_dns_zone.private_dns_zone_id

  # System node pool
  system_node_pool_name             = var.system_node_pool_name
  system_node_pool_vm_size         = var.system_node_pool_vm_size
  system_node_pool_enable_auto_scaling = var.system_node_pool_enable_auto_scaling
  system_node_pool_min_count       = var.system_node_pool_min_count
  system_node_pool_max_count       = var.system_node_pool_max_count
  system_node_pool_os_disk_size_gb = var.system_node_pool_os_disk_size_gb
  system_node_pool_zones           = var.system_node_pool_zones

  # Work node pool
  work_node_pool_name             = var.work_node_pool_name
  work_node_pool_vm_size         = var.work_node_pool_vm_size
  work_node_pool_enable_auto_scaling = var.work_node_pool_enable_auto_scaling
  work_node_pool_min_count       = var.work_node_pool_min_count
  work_node_pool_max_count       = var.work_node_pool_max_count
  work_node_pool_os_disk_size_gb = var.work_node_pool_os_disk_size_gb
  work_node_pool_zones           = var.work_node_pool_zones

  # Security and identity
  identity_type         = var.identity_type
  admin_group_object_ids = var.admin_group_object_ids
  enable_defender       = var.enable_defender
  enable_workload_identity = var.enable_workload_identity
  enable_oidc_issuer    = var.enable_oidc_issuer

  # Monitoring and maintenance
  log_analytics_workspace_id = var.log_analytics_workspace_id
  azure_policy_enabled      = var.azure_policy_enabled
  maintenance_window        = var.maintenance_window
  automatic_channel_upgrade = var.automatic_channel_upgrade

  tags = var.tags

  depends_on = [
    module.virtual_network,
    module.subnet
  ]
}