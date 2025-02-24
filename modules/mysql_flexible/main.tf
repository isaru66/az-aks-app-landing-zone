# Azure MySQL Flexible Server Module
# This module creates a MySQL Flexible Server instance with high availability, monitoring, and security configurations

# Main MySQL Flexible Server resource
# Configures the primary database server with specified settings for HA, storage, and maintenance
resource "azurerm_mysql_flexible_server" "mysql" {
  # Basic server configuration
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  
  # Server specifications
  backup_retention_days  = var.backup_retention_days
  version               = var.mysql_version
  sku_name              = var.sku_name
  
  # Network configuration
  delegated_subnet_id   = var.subnet_id
  private_dns_zone_id   = var.private_dns_zone_id
  zone                  = var.zone

  # Storage configuration
  storage {
    iops    = var.storage_iops
    size_gb = var.storage_size_gb
  }

  # High Availability configuration
  high_availability {
    mode                      = var.high_availability_mode
    standby_availability_zone = var.standby_availability_zone
  }

  # Maintenance window configuration
  maintenance_window {
    day_of_week  = var.maintenance_window.day_of_week
    start_hour   = var.maintenance_window.start_hour
    start_minute = var.maintenance_window.start_minute
  }

  # Identity configuration for Azure AD integration
  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]  # Use the provided identity ID
  }

  tags = var.tags
}

# Security configurations
# Enforce secure transport for all connections
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "ON"  # Ensures that all connections must use SSL/TLS
}

# Enforce TLS 1.2 for enhanced security
resource "azurerm_mysql_flexible_server_configuration" "tls_version" {
  name                = "tls_version"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "TLSv1.2"  # Enforces TLS 1.2 as the minimum version
}

# Network security configuration
# Configure firewall rule to allow access from the specified subnet
resource "azurerm_mysql_flexible_server_firewall_rule" "vnet" {
  name                = "allow-vnet"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = cidrhost(var.subnet_cidr, 0)    # First IP in subnet
  end_ip_address      = cidrhost(var.subnet_cidr, -1)   # Last IP in subnet
}

# resource "azurerm_monitor_diagnostic_setting" "mysql" {
#   name                        = coalesce(var.diagnostic_setting_name, "jm-mysql-server-diagnostics")
#   target_resource_id          = azurerm_mysql_flexible_server.mysql.id
#   log_analytics_workspace_id  = var.log_analytics_workspace_id
  
#   enabled_log {
#     category_group = "allLogs"
#   }
  
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
  
#   depends_on = [azurerm_mysql_flexible_server.mysql]
# }