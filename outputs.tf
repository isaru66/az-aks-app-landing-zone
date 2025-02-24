# Resource Group and Network outputs
output "network_info" {
  description = "Network-related information"
  value = {
    resource_group_name     = azurerm_resource_group.this.name
    virtual_network_name    = module.virtual_network.virtual_network_name
    network_security_group_id = module.network_security_group.network_security_group_id
    subnet_ids             = { for k, v in module.subnet : k => v.subnet_id }
    subnet_names           = { for k, v in module.subnet : k => v.subnet_name }
  }
  sensitive = true
}

# AKS Cluster outputs
output "aks_info" {
  description = "AKS cluster information"
  value = {
    cluster_id       = module.aks.cluster_id
    cluster_name     = module.aks.cluster_name
    cluster_fqdn     = module.aks.cluster_fqdn
    oidc_issuer_url  = module.aks.oidc_issuer_url
    kubelet_identity = module.aks.kubelet_identity
  }
  sensitive = true
}

# ACR outputs
output "acr_info" {
  description = "Container Registry information"
  value = {
    id                  = module.acr.acr_id
    login_server        = module.acr.acr_login_server
    private_endpoint_ip = module.acr.private_endpoint_ip
  }
  sensitive = true
}

# MySQL Flexible Server outputs
output "mysql_info" {
  description = "MySQL Flexible Server information"
  value = {
    server_id   = module.mysql.server_id
    server_name = module.mysql.server_name
    server_fqdn = module.mysql.server_fqdn
  }
  sensitive = true
}