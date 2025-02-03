resource "azurerm_subnet" "this" {
  name                = var.subnet_name
  resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes    = [var.address_prefix]
}

# Add NSG association as a separate resource
resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}