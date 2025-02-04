resource "azurerm_key_vault" "vault" {
  name                            = var.name
  location                        = var.location
  resource_group_name            = var.resource_group_name
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  sku_name                       = var.sku_name
  enabled_for_deployment         = var.enabled_for_deployment
  enabled_for_disk_encryption    = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  purge_protection_enabled       = var.purge_protection_enabled
  soft_delete_retention_days     = var.soft_delete_retention_days
  enable_rbac_authorization      = true

  network_acls {
    bypass                     = var.network_acls.bypass
    default_action            = var.network_acls.default_action
    ip_rules                  = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "vault" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.vault.id
    is_manual_connection          = false
    subresource_names            = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

data "azurerm_client_config" "current" {}
