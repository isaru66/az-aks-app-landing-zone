output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.vault.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.vault.vault_uri
}

output "private_endpoint_ip" {
  description = "The private IP address of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.vault.private_service_connection[0].private_ip_address
}
