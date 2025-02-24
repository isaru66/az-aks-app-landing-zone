resource "azurerm_storage_account" "storage" {
  name                             = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"  # Zone-redundant storage for production
  min_tls_version                = "TLS1_2"
  public_network_access_enabled   = false
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = []
    virtual_network_subnet_ids = []
  }

  blob_properties {
    container_delete_retention_policy {
      days = 30  # Increased retention for production
    }
    delete_retention_policy {
      days = 30
    }
    versioning_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Private endpoint for secure access
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

# RBAC for blob data access
resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.principal_id
}

// Updated diagnostic settings
# resource "azurerm_monitor_diagnostic_setting" "storage" {
#   name                       = "${var.storage_account_name}-diagnostics"
#   target_resource_id         = azurerm_storage_account.storage.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   metric {
#     category = "Transaction"
#     enabled  = true
#   }

#   metric {
#     category = "Capacity"
#     enabled  = true
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "blob_diagnostic" {
#   name                       = "${var.storage_account_name}-blob-diagnostics"
#   target_resource_id         = "${azurerm_storage_account.storage.id}/blobServices/default"
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category_group = "audit"
#   }

#   enabled_log {
#     category_group = "allLogs"
#   }

#   metric {
#     category = "Transaction"
#     enabled  = true
#   }

#   metric {
#     category = "Capacity"
#     enabled  = true
#   }

#   lifecycle {
#     create_before_destroy = true
#     replace_triggered_by = [
#       azurerm_storage_account.storage.id
#     ]
#   }
# }

