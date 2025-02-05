# Create a random suffix for uniqueness
resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Use the random suffix in ACR name
resource "azurerm_container_registry" "acr" {
  name                          = "acr${random_string.acr_suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku                         = var.sku
  admin_enabled               = false
  public_network_access_enabled = false
  zone_redundancy_enabled     = true
  
  identity {
    type = "SystemAssigned"
  }

  network_rule_set {
    default_action = "Deny"
    ip_rule        = []
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