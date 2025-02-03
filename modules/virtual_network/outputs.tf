output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.this.name
}

output "virtual_network_address_space" {
  value = azurerm_virtual_network.this.address_space
}