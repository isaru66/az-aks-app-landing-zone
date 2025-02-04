data "azurerm_client_config" "current" {}

resource "azuread_group" "aks_admins" {
  display_name     = var.group_name
  description      = var.description
  security_enabled = true
  owners           = var.group_owners != null ? var.group_owners : [data.azurerm_client_config.current.object_id]
}

# Assign Azure Kubernetes Service Cluster Admin Role only if cluster ID is provided
resource "azurerm_role_assignment" "aks_cluster_admin" {
  count               = var.aks_cluster_id != null ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_group.aks_admins.object_id
}