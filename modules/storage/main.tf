resource "azurerm_storage_account" "storage" {
  name                          = var.storage_account_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  account_tier                 = "Standard"
  account_replication_type     = "GRS"
  min_tls_version             = "TLS1_2"
  public_network_access_enabled = false

  infrastructure_encryption_enabled = true
  
  queue_encryption_key_type    = "Service"
  table_encryption_key_type    = "Service"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days = 7
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.user_assigned_identity_ids : null
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${var.storage_account_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection          = false
    subresource_names             = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
