resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  upper   = false
}

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

module "storage" {
  source              = "./modules/storage"
  storage_account_name = "st${var.environment}${random_string.storage_account_suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location           = azurerm_resource_group.this.location
  environment        = var.environment
  subnet_id          = module.subnet["pe-subnet"].subnet_id
  private_dns_zone_id = module.private_dns_zone.private_dns_zone_id
  principal_id       = module.storage_access_group.group_object_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags = var.tags

  depends_on = [
    module.virtual_network,
    module.subnet,
    module.private_dns_zone,
    module.log_analytics
  ]
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  workspace_name      = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = var.log_analytics_retention_days
  sku                = var.log_analytics_workspace_sku
  tags                = var.tags
}

# Azure AD Group for AKS Admins - creating this before AKS cluster
module "aks_admin_group" {
  source = "./modules/aad_group"
  group_name  = "${var.aks_cluster_name}-admins"
  description = "AKS cluster administrators for ${var.aks_cluster_name}"
}

# Azure AD Group for Storage Account Access
module "storage_access_group" {
  source      = "./modules/aad_group"
  group_name  = "storage-access-group"
  description = "Group for storage account access"
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
  admin_group_object_ids = [module.aks_admin_group.group_object_id]
  enable_defender       = var.enable_defender
  enable_workload_identity = var.enable_workload_identity
  enable_oidc_issuer    = var.enable_oidc_issuer

  # Monitoring and maintenance
  azure_policy_enabled      = var.azure_policy_enabled
  maintenance_window        = var.maintenance_window
  automatic_channel_upgrade = var.automatic_channel_upgrade
  enable_managed_prometheus = var.enable_managed_prometheus
  grafana_name             = var.grafana_name

  # Log Analytics configuration
  log_analytics_workspace_id = module.log_analytics.workspace_id

  # Attach ACR
  attach_acr = true
  acr_id     = module.acr.acr_id

  tags = var.tags

  depends_on = [
    module.virtual_network,
    module.subnet,
    module.log_analytics,
    module.acr,
    module.private_dns_zone
  ]
}

# Grant admin role after cluster is created
resource "azurerm_role_assignment" "aks_admin_group" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = module.aks_admin_group.group_object_id
  depends_on          = [module.aks]
}

module "bastion" {
  source = "./modules/bastion"

  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.subnet["AzureBastionSubnet"].subnet_id
  tags                = var.tags

  depends_on = [
    module.virtual_network,
    module.subnet
  ]
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
  tags               = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = module.virtual_network.virtual_network_id
  registration_enabled  = false
  tags                 = var.tags
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.this.name
  tags               = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "acr-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = module.virtual_network.virtual_network_id
  registration_enabled  = false
  tags                 = var.tags
}

module "key_vault" {
  source = "./modules/keyvault"

  name                = var.keyvault_name
  resource_group_name = azurerm_resource_group.this.name
  location           = var.location
  sku_name           = var.keyvault_sku

  network_acls            = var.keyvault_network_acls
  private_endpoint_subnet_id = module.subnet["pe-subnet"].subnet_id
  private_dns_zone_ids    = [azurerm_private_dns_zone.keyvault.id]

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone.keyvault,
    azurerm_private_dns_zone_virtual_network_link.keyvault,
    module.subnet
  ]
}

module "acr" {
  source = "./modules/acr"

  name                = var.acr_name
  resource_group_name = azurerm_resource_group.this.name
  location           = var.location
  sku               = var.acr_sku

  public_network_access_enabled = var.acr_public_access_enabled
  subnet_id                    = module.subnet["pe-subnet"].subnet_id
  private_dns_zone_ids         = [azurerm_private_dns_zone.acr.id]

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone.acr,
    azurerm_private_dns_zone_virtual_network_link.acr,
    module.subnet
  ]
}