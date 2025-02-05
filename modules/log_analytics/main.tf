resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                = var.sku
  retention_in_days   = var.retention_in_days
  
  internet_ingestion_enabled = true
  internet_query_enabled    = true
  local_authentication_disabled = false
  
  tags = var.tags
}
