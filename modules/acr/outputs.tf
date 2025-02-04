output "acr_id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "The login server URL of the Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "principal_id" {
  description = "The Principal ID of the Container Registry system-assigned identity"
  value       = azurerm_container_registry.acr.identity[0].principal_id
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = azurerm_private_endpoint.acr_pe.private_service_connection[0].private_ip_address
}