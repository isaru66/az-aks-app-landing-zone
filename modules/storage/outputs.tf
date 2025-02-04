output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = azurerm_private_endpoint.storage_pe.private_service_connection[0].private_ip_address
}
