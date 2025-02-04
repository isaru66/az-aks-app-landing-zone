output "workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_customer_id" {
  description = "The Workspace (Customer) ID"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "The Primary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}