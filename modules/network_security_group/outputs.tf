output "network_security_group_id" {
  value = azurerm_network_security_group.this.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.this.name
}

output "network_security_group_location" {
  value = azurerm_network_security_group.this.location
}