# Azure MySQL Flexible Server Module

A Terraform module for deploying Azure Database for MySQL Flexible Server with comprehensive configurations for high availability, security, monitoring, and networking.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check MySQL permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'MySQL')].roleDefinitionName" \
    -o tsv

# Assign MySQL Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "MySQL Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Network Prerequisites
```bash
# Create subnet for MySQL delegation
az network vnet subnet create \
    --name "mysql-subnet" \
    --resource-group "your-rg" \
    --vnet-name "your-vnet" \
    --address-prefix "10.0.3.0/24" \
    --delegations "Microsoft.DBforMySQL/flexibleServers"

# Create private DNS zone
az network private-dns zone create \
    --resource-group "your-rg" \
    --name "privatelink.mysql.database.azure.net"

# Link private DNS zone to VNet
az network private-dns link vnet create \
    --resource-group "your-rg" \
    --zone-name "privatelink.mysql.database.azure.net" \
    --name "mysql-dns-link" \
    --virtual-network "your-vnet" \
    --registration-enabled false
```

## Features
- Flexible server deployment with high availability
- Private networking with subnet delegation
- Automated backup configuration
- Point-in-time restore capabilities
- Maintenance window scheduling
- Performance tier selection
- Storage auto-growth
- SSL enforcement
- Firewall rules
- Parameter customization
- Monitoring integration

## Usage

```hcl
module "mysql_flexible" {
  source = "./modules/mysql_flexible"

  # Basic Configuration
  name                = "mysql-flex-prod"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  
  # Admin credentials (store securely in Key Vault)
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  
  # Server Configuration
  sku_name      = "GP_Standard_D4ds_v4"
  version       = "8.0.21"
  storage_mb    = 32768
  zone          = "1"
  
  # High Availability
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  
  # Backup Configuration
  backup_retention_days        = 30
  geo_redundant_backup_enabled = true
  
  # Network Configuration
  delegated_subnet_id = module.subnet["mysql"].id
  private_dns_zone_id = module.private_dns_zone["mysql"].id
  
  # Maintenance Window
  maintenance_window = {
    day_of_week  = 0
    start_hour   = 3
    start_minute = 0
  }
  
  # Firewall Rules (if needed)
  firewall_rules = {
    "AllowAKS" = {
      start_ip_address = "10.0.0.0"
      end_ip_address   = "10.0.3.255"
    }
  }
  
  # Optional MySQL Parameters
  mysql_configurations = {
    "slow_query_log"      = "ON"
    "long_query_time"     = "2"
    "max_connections"     = "1000"
    "interactive_timeout" = "28800"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Server name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| administrator_login | Admin username | string | yes | - |
| administrator_password | Admin password | string | yes | - |
| sku_name | SKU name | string | no | "GP_Standard_D2ds_v4" |
| version | MySQL version | string | no | "8.0.21" |
| storage_mb | Storage in MB | number | no | 32768 |
| backup_retention_days | Backup retention days | number | no | 7 |
| geo_redundant_backup_enabled | Enable geo-redundant backup | bool | no | false |
| zone | Availability zone | string | no | "1" |
| high_availability | HA configuration | object | no | null |
| delegated_subnet_id | Subnet ID | string | yes | - |
| private_dns_zone_id | Private DNS zone ID | string | yes | - |
| maintenance_window | Maintenance window config | object | no | null |
| firewall_rules | Firewall rules | map(object) | no | {} |
| mysql_configurations | MySQL parameters | map(string) | no | {} |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| server_id | The MySQL Server ID |
| server_fqdn | The FQDN of the server |
| server_name | The name of the server |
| administrator_login | The administrator username |
| version | The version of MySQL |

## Best Practices

### Security
- Use private networking
- Enable SSL enforcement
- Implement firewall rules
- Regular password rotation
- Monitor access logs
- Encrypt backups
- Use managed identities
- Regular security audits

### Performance
- Choose appropriate SKU
- Monitor resource usage
- Configure auto-scaling
- Optimize queries
- Regular maintenance
- Monitor connections
- Configure caching
- Index optimization

### High Availability
- Enable zone redundancy
- Configure backups
- Test failover
- Monitor replication
- Plan maintenance
- Document procedures
- Regular testing
- Monitor latency

### Monitoring
- Enable diagnostic logs
- Configure alerts
- Monitor metrics
- Track performance
- Query analysis
- Resource utilization
- Backup status
- Security events

### Cost Management
- Right-size instances
- Monitor storage
- Backup retention
- Performance tier
- Resource scheduling
- Usage monitoring
- Cost allocation
- Budget alerts

### Backup and Recovery
- Regular backups
- Geo-redundant storage
- Point-in-time recovery
- Test restores
- Document procedures
- Monitor success
- Retention policy
- Secure storage