resource "azurerm_container_registry" "acr" {
  name                          = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku                         = var.sku
  admin_enabled               = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  
  identity {
    type = "SystemAssigned"
  }

  network_rule_set {
    default_action = "Deny"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection          = false
    subresource_names            = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}