output "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = azurerm_private_dns_zone.aks.id
}

output "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  value       = azurerm_private_dns_zone.aks.name
}

output "virtual_network_link_id" {
  description = "ID of the virtual network link"
  value       = azurerm_private_dns_zone_virtual_network_link.aks.id
}