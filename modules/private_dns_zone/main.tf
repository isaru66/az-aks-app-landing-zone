# Private DNS Zone for AKS
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${replace(lower(var.location), " ", "")}.azmk8s.io"
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

# Link the DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "aks-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = var.virtual_network_id
  
  tags = var.tags
}